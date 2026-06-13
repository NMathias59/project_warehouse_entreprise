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

Configuration requise (Airflow UI → Admin → Variables) :
    airbyte_connection_id_erp   → UUID connexion ERP dans Airbyte
    airbyte_connection_id_crm   → UUID connexion CRM dans Airbyte
    airbyte_connection_id_mkt   → UUID connexion MKT dans Airbyte

    Si Airbyte OSS requiert une authentification HTTP basic :
    airbyte_username  → (défaut : airbyte)
    airbyte_password  → (défaut : password)
"""

from __future__ import annotations

import time
from datetime import datetime, timedelta

import requests

from airflow.decorators import dag
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.sdk import Variable

from include.constants import (
    AIRBYTE_API_URL,
    AIRBYTE_CLIENT_ID,
    AIRBYTE_CLIENT_SECRET,
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


# ─── Helpers ──────────────────────────────────────────────────────────────────

def _dbt(verb: str, select: str) -> str:
    return (
        f'cd {WAREHOUSE_DIR} '
        f'&& {DBT_BIN} {verb} --profiles-dir . '
        f'--select "{select}"'
    )


def _get_airbyte_token() -> str:
    """Obtient un token OAuth2 Airbyte via Client Credentials (abctl)."""
    resp = requests.post(
        f"{AIRBYTE_API_URL}/api/v1/applications/token",
        json={
            "client_id": AIRBYTE_CLIENT_ID,
            "client_secret": AIRBYTE_CLIENT_SECRET,
            "grant_type": "client_credentials",
        },
        timeout=30,
    )
    resp.raise_for_status()
    return resp.json()["access_token"]


_TERMINAL_STATUSES = {"succeeded", "failed", "cancelled", "incomplete"}

def _get_active_job_id(connection_id: str, headers: dict) -> str | None:
    """Retourne l'ID du dernier job non-terminal sur cette connexion, ou None."""
    resp = requests.get(
        f"{AIRBYTE_API_URL}/api/public/v1/jobs",
        params={"connectionId": connection_id, "limit": 10},
        headers=headers,
        timeout=30,
    )
    resp.raise_for_status()
    for job in resp.json().get("data", []):
        if job.get("status") not in _TERMINAL_STATUSES:
            return job["jobId"]
    return None


def _run_airbyte_sync(connection_id_var: str, timeout: int = 3600) -> None:
    """Déclenche une sync Airbyte (Platform API public/v1) et attend sa complétion."""
    connection_id = Variable.get(connection_id_var)
    token = _get_airbyte_token()
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}

    resp = requests.post(
        f"{AIRBYTE_API_URL}/api/public/v1/jobs",
        json={"connectionId": connection_id, "jobType": "sync"},
        headers=headers,
        timeout=30,
    )

    if resp.status_code == 409:
        # Un job tourne déjà — on le récupère et on attend sa fin
        job_id = _get_active_job_id(connection_id, headers)
        if not job_id:
            resp.raise_for_status()  # 409 sans job actif = erreur inattendue
    else:
        resp.raise_for_status()
        job_id = resp.json()["jobId"]

    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        time.sleep(15)
        status_resp = requests.get(
            f"{AIRBYTE_API_URL}/api/public/v1/jobs/{job_id}",
            headers=headers,
            timeout=30,
        )
        status_resp.raise_for_status()
        status = status_resp.json()["status"]
        if status == "succeeded":
            return
        if status in _TERMINAL_STATUSES:
            raise RuntimeError(f"Airbyte sync {connection_id} terminée en erreur : {status}")

    raise TimeoutError(f"Airbyte sync {connection_id} n'a pas abouti en {timeout}s")


def _airbyte_sync(task_id: str, connection_id_var: str) -> PythonOperator:
    return PythonOperator(
        task_id=task_id,
        python_callable=_run_airbyte_sync,
        op_kwargs={"connection_id_var": connection_id_var},
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

default_args: dict = {
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

    sync_erp = _airbyte_sync("airbyte_sync_erp", "airbyte_connection_id_erp")
    run_erp, test_erp = _dbt_domain("erp", DBT_SELECT_ERP)
    sync_erp >> run_erp

    sync_crm = _airbyte_sync("airbyte_sync_crm", "airbyte_connection_id_crm")
    run_crm, test_crm = _dbt_domain("crm", DBT_SELECT_CRM)
    sync_crm >> run_crm

    sync_mkt = _airbyte_sync("airbyte_sync_mkt", "airbyte_connection_id_mkt")
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
