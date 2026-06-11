"""
Pipeline principal warehouse — déclenché chaque nuit à 3h.

Chaque source Airbyte et chaque datamart métier ont leur propre pipeline.
Les domaines sans dépendances croisées tournent en parallèle.

Séquence :

  Phase 1+2 — Sync + warehouse (3 pipelines parallèles) :
    sync_erp → run_erp → test_erp ──┐
    sync_crm → run_crm → test_crm ──┤ (attendent les 3 pour démarrer le BI)
    sync_mkt → run_mkt → test_mkt ──┘

  Phase 3 — BI datamarts (parallèle sauf dépendance LOGISTIQUE → PRODUCTION) :
    ├─ run_bi_production → test_bi_production ──► run_bi_logistique → test_bi_logistique
    ├─ run_bi_marketing  → test_bi_marketing
    ├─ run_bi_finance    → test_bi_finance
    ├─ run_bi_rh         → test_bi_rh
    └─ run_bi_sav        → test_bi_sav

  Dépendance cross-BI : bi_log__shortage_coverage ref() bi_prod__bom_vs_stock
  → BI_LOGISTIQUE ne peut démarrer qu'après test_bi_production.

Configuration requise avant le premier run :
    Airflow UI → Admin → Connections → créer :
      conn_id   : airbyte_default
      conn_type : HTTP
      host      : host.docker.internal
      port      : 8006

    Airflow UI → Admin → Variables → créer :
      airbyte_connection_id_erp   → UUID connexion ERP  dans Airbyte
      airbyte_connection_id_crm   → UUID connexion CRM  dans Airbyte
      airbyte_connection_id_mkt   → UUID connexion MKT  dans Airbyte
"""

from __future__ import annotations

from datetime import datetime, timedelta

from airflow.decorators import dag
from airflow.models import Variable
from airflow.operators.bash import BashOperator
from airflow.providers.airbyte.operators.airbyte import AirbyteTriggerSyncOperator

from include.constants import (
    AIRBYTE_CONN_ID,
    DBT_BIN,
    DBT_SELECT_BI_FINANCE,
    DBT_SELECT_BI_LOGISTIQUE,
    DBT_SELECT_BI_MARKETING,
    DBT_SELECT_BI_PRODUCTION,
    DBT_SELECT_BI_RH,
    DBT_SELECT_BI_SAV,
    DBT_SELECT_CRM,
    DBT_SELECT_ERP,
    DBT_SELECT_MKT,
    WAREHOUSE_DIR,
)

# ─── Airflow Variables ────────────────────────────────────────────────────────
_CONN_ERP = Variable.get("airbyte_connection_id_erp", default_var="<ERP_UUID>")
_CONN_CRM = Variable.get("airbyte_connection_id_crm", default_var="<CRM_UUID>")
_CONN_MKT = Variable.get("airbyte_connection_id_mkt", default_var="<MKT_UUID>")


# ─── Helpers ──────────────────────────────────────────────────────────────────

def _dbt(verb: str, select: str) -> str:
    return (
        f'cd {WAREHOUSE_DIR} '
        f'&& {DBT_BIN} {verb} --profiles-dir . '
        f'--select "{select}"'
    )


def _airbyte_sync(task_id: str, connection_id: str) -> AirbyteTriggerSyncOperator:
    return AirbyteTriggerSyncOperator(
        task_id=task_id,
        airbyte_conn_id=AIRBYTE_CONN_ID,
        connection_id=connection_id,
        asynchronous=False,
        timeout=3600,
        wait_seconds=15,
    )


def _dbt_domain(
    domain: str,
    select: str,
) -> tuple[BashOperator, BashOperator]:
    """Crée le couple (run, test) pour un domaine dbt. run >> test câblé en interne."""
    run = BashOperator(
        task_id=f"dbt_run_{domain}",
        bash_command=_dbt("run", select),
        retries=0,
    )
    test = BashOperator(
        task_id=f"dbt_test_{domain}",
        bash_command=_dbt("test", select),
        retries=0,
    )
    run >> test
    return run, test


# ─── DAG ──────────────────────────────────────────────────────────────────────

default_args = {
    "owner":            "data-team",
    "retries":          2,
    "retry_delay":      timedelta(minutes=10),
    "email_on_failure": False,
}


@dag(
    dag_id="warehouse_pipeline",
    description="Airbyte syncs → dbt ERP/CRM/MKT → dbt BI datamarts (par domaine)",
    schedule="0 3 * * *",
    start_date=datetime(2026, 6, 1),
    catchup=False,
    max_active_runs=1,
    default_args=default_args,
    tags=["warehouse", "dbt", "airbyte"],
)
def warehouse_pipeline() -> None:

    # ── Phase 1+2 : Sync Airbyte → dbt warehouse (3 pipelines parallèles) ────

    sync_erp = _airbyte_sync("airbyte_sync_erp", _CONN_ERP)
    run_erp, test_erp = _dbt_domain("erp", DBT_SELECT_ERP)
    sync_erp >> run_erp

    sync_crm = _airbyte_sync("airbyte_sync_crm", _CONN_CRM)
    run_crm, test_crm = _dbt_domain("crm", DBT_SELECT_CRM)
    sync_crm >> run_crm

    sync_mkt = _airbyte_sync("airbyte_sync_mkt", _CONN_MKT)
    run_mkt, test_mkt = _dbt_domain("mkt", DBT_SELECT_MKT)
    sync_mkt >> run_mkt

    # ── Phase 3 : BI datamarts ────────────────────────────────────────────────
    # Condition d'entrée : les 3 tests warehouse doivent être verts.

    warehouse_tests_ok = [test_erp, test_crm, test_mkt]

    # BI_PRODUCTION — aucune dépendance BI croisée, peut démarrer directement
    run_bi_prod, test_bi_prod = _dbt_domain("bi_production", DBT_SELECT_BI_PRODUCTION)
    warehouse_tests_ok >> run_bi_prod

    # BI_LOGISTIQUE — dépend de BI_PRODUCTION (bi_log__shortage_coverage
    # utilise bi_prod__bom_vs_stock via ref())
    run_bi_log, test_bi_log = _dbt_domain("bi_logistique", DBT_SELECT_BI_LOGISTIQUE)
    test_bi_prod >> run_bi_log

    # BI_MARKETING, BI_FINANCE, BI_RH, BI_SAV — indépendants, parallèles
    run_bi_mkt, test_bi_mkt = _dbt_domain("bi_marketing",  DBT_SELECT_BI_MARKETING)
    run_bi_fin, test_bi_fin = _dbt_domain("bi_finance",    DBT_SELECT_BI_FINANCE)
    run_bi_rh,  test_bi_rh  = _dbt_domain("bi_rh",         DBT_SELECT_BI_RH)
    run_bi_sav, test_bi_sav = _dbt_domain("bi_sav",        DBT_SELECT_BI_SAV)

    for run_bi in [run_bi_mkt, run_bi_fin, run_bi_rh, run_bi_sav]:
        warehouse_tests_ok >> run_bi


warehouse_pipeline()
