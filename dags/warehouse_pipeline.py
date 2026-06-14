"""
Pipeline principal warehouse — déclenché chaque nuit à 3h.

Séquence :

  Phase 1+2 — Sync Airbyte + dbt warehouse (12 domaines en parallèle) :

    [sync_erp →]         run_erp         → test_erp         ──┐
    [sync_crm →]         run_crm         → test_crm         ──┤
    [sync_mkt →]         run_mkt         → test_mkt         ──┤
    [sync_wms →]         run_wms         → test_wms         ──┤
    [sync_mes →]         run_mes         → test_mes         ──┤
    [sync_marketing →]   run_marketing   → test_marketing   ──┤ (attendent les 12 → BI)
    [sync_sav →]         run_sav         → test_sav         ──┤
    [sync_plm →]         run_plm         → test_plm         ──┤
    [sync_sirh →]        run_sirh        → test_sirh        ──┤
    [sync_qms →]         run_qms         → test_qms         ──┤
    [sync_finance →]     run_finance     → test_finance     ──┤
    [sync_procurement →] run_procurement → test_procurement ──┘

  [sync_*] = présent uniquement si AIRBYTE_CONN_<DOMAIN> est défini dans .env.
  Sans UUID Airbyte, dbt tourne sur les sources existantes (tables vides = OK).

  Phase 3 — BI datamarts (parallèle sauf dépendance LOGISTIQUE → PRODUCTION) :
    ├─ run_bi_production → test_bi_production ──► run_bi_logistique → test_bi_logistique
    ├─ run_bi_marketing  → test_bi_marketing
    ├─ run_bi_finance    → test_bi_finance
    ├─ run_bi_rh         → test_bi_rh
    └─ run_bi_sav        → test_bi_sav

  Dépendance cross-BI : bi_log__shortage_coverage ref() bi_prod__bom_vs_stock
  → BI_LOGISTIQUE ne peut démarrer qu'après test_bi_production.

Config Airbyte (credentials + UUIDs) dans .env — voir include/constants.py.
"""

from __future__ import annotations

import time
from datetime import datetime, timedelta

import requests

from airflow.decorators import dag
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator

from include.constants import (
    AIRBYTE_API_URL,
    AIRBYTE_CLIENT_ID,
    AIRBYTE_CLIENT_SECRET,
    AIRBYTE_CONN_CRM,
    AIRBYTE_CONN_ERP,
    AIRBYTE_CONN_FINANCE,
    AIRBYTE_CONN_MARKETING,
    AIRBYTE_CONN_MES,
    AIRBYTE_CONN_MKT,
    AIRBYTE_CONN_PLM,
    AIRBYTE_CONN_PROCUREMENT,
    AIRBYTE_CONN_QMS,
    AIRBYTE_CONN_SAV,
    AIRBYTE_CONN_SIRH,
    AIRBYTE_CONN_WMS,
    DBT_BIN,
    DBT_SELECT_BI_FINANCE,
    DBT_SELECT_BI_LOGISTIQUE,
    DBT_SELECT_BI_MARKETING,
    DBT_SELECT_BI_PRODUCTION,
    DBT_SELECT_BI_RH,
    DBT_SELECT_BI_SAV,
    DBT_SELECT_CRM,
    DBT_SELECT_ERP,
    DBT_SELECT_FINANCE,
    DBT_SELECT_MARKETING,
    DBT_SELECT_MES,
    DBT_SELECT_MKT,
    DBT_SELECT_PLM,
    DBT_SELECT_PROCUREMENT,
    DBT_SELECT_QMS,
    DBT_SELECT_SAV,
    DBT_SELECT_SIRH,
    DBT_SELECT_WMS,
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


def _run_airbyte_sync(connection_id: str, timeout: int = 3600) -> None:
    """Déclenche une sync Airbyte (Platform API public/v1) et attend sa complétion."""
    token = _get_airbyte_token()
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}

    resp = requests.post(
        f"{AIRBYTE_API_URL}/api/public/v1/jobs",
        json={"connectionId": connection_id, "jobType": "sync"},
        headers=headers,
        timeout=30,
    )

    if resp.status_code == 409:
        job_id = _get_active_job_id(connection_id, headers)
        if not job_id:
            resp.raise_for_status()
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


def _dbt_domain(domain: str, select: str) -> tuple[BashOperator, BashOperator]:
    """Crée le couple (run, test) pour un domaine dbt. run >> test câblé en interne."""
    run = BashOperator(
        task_id=f"dbt_run_{domain}",
        bash_command=_dbt("run", select),
        retries=1,
        retry_delay=timedelta(minutes=2),
    )
    test = BashOperator(
        task_id=f"dbt_test_{domain}",
        bash_command=_dbt("test", select),
        retries=0,
    )
    run >> test
    return run, test


def _domain_pipeline(
    domain: str,
    select: str,
    conn_id: str | None = None,
) -> tuple[BashOperator, BashOperator]:
    """
    Crée sync → run → test si conn_id est fourni, sinon run → test uniquement.
    Retourne (run, test) dans les deux cas pour le câblage des dépendances.
    """
    run, test = _dbt_domain(domain, select)
    if conn_id:
        sync = PythonOperator(
            task_id=f"airbyte_sync_{domain}",
            python_callable=_run_airbyte_sync,
            op_kwargs={"connection_id": conn_id},
            retries=0,
        )
        sync >> run
    return run, test


# ─── DAG ──────────────────────────────────────────────────────────────────────

default_args: dict = {
    "owner":            "data-team",
    "retries":          0,
    "retry_delay":      timedelta(minutes=2),
    "email_on_failure": False,
}


@dag(
    dag_id="warehouse_pipeline",
    description="Airbyte syncs → dbt (12 domaines) → BI datamarts",
    schedule="0 3 * * *",
    start_date=datetime(2026, 6, 1),
    catchup=False,
    max_active_runs=1,
    default_args=default_args,
    tags=["warehouse", "dbt", "airbyte"],
)
def warehouse_pipeline() -> None:

    # ── Phase 1+2 : 12 domaines en parallèle ─────────────────────────────────
    # Domaines initiaux — connexions Airbyte obligatoires
    _, test_erp  = _domain_pipeline("erp",  DBT_SELECT_ERP,  AIRBYTE_CONN_ERP)
    _, test_crm  = _domain_pipeline("crm",  DBT_SELECT_CRM,  AIRBYTE_CONN_CRM)
    _, test_mkt  = _domain_pipeline("mkt",  DBT_SELECT_MKT,  AIRBYTE_CONN_MKT)

    # Nouveaux domaines — sync Airbyte conditionnel (None si UUID absent du .env)
    _, test_wms         = _domain_pipeline("wms",         DBT_SELECT_WMS,         AIRBYTE_CONN_WMS)
    _, test_mes         = _domain_pipeline("mes",         DBT_SELECT_MES,         AIRBYTE_CONN_MES)
    _, test_marketing   = _domain_pipeline("marketing",   DBT_SELECT_MARKETING,   AIRBYTE_CONN_MARKETING)
    _, test_sav         = _domain_pipeline("sav",         DBT_SELECT_SAV,         AIRBYTE_CONN_SAV)
    _, test_plm         = _domain_pipeline("plm",         DBT_SELECT_PLM,         AIRBYTE_CONN_PLM)
    _, test_sirh        = _domain_pipeline("sirh",        DBT_SELECT_SIRH,        AIRBYTE_CONN_SIRH)
    _, test_qms         = _domain_pipeline("qms",         DBT_SELECT_QMS,         AIRBYTE_CONN_QMS)
    _, test_finance     = _domain_pipeline("finance",     DBT_SELECT_FINANCE,     AIRBYTE_CONN_FINANCE)
    _, test_procurement = _domain_pipeline("procurement", DBT_SELECT_PROCUREMENT, AIRBYTE_CONN_PROCUREMENT)

    # ── Phase 3 : BI datamarts ────────────────────────────────────────────────
    # Condition d'entrée : tous les tests des 12 domaines doivent être verts.
    all_domain_tests = [
        test_erp, test_crm, test_mkt,
        test_wms, test_mes, test_marketing, test_sav,
        test_plm, test_sirh, test_qms, test_finance, test_procurement,
    ]

    # BI_PRODUCTION — aucune dépendance BI croisée
    run_bi_prod, test_bi_prod = _dbt_domain("bi_production", DBT_SELECT_BI_PRODUCTION)
    all_domain_tests >> run_bi_prod

    # BI_LOGISTIQUE — dépend de BI_PRODUCTION (bi_log__shortage_coverage ref() bi_prod__bom_vs_stock)
    run_bi_log, test_bi_log = _dbt_domain("bi_logistique", DBT_SELECT_BI_LOGISTIQUE)
    test_bi_prod >> run_bi_log

    # BI_MARKETING, BI_FINANCE, BI_RH, BI_SAV — indépendants, parallèles
    run_bi_mkt, _ = _dbt_domain("bi_marketing", DBT_SELECT_BI_MARKETING)
    run_bi_fin, _ = _dbt_domain("bi_finance",   DBT_SELECT_BI_FINANCE)
    run_bi_rh,  _ = _dbt_domain("bi_rh",        DBT_SELECT_BI_RH)
    run_bi_sav, _ = _dbt_domain("bi_sav",       DBT_SELECT_BI_SAV)

    for run_bi in [run_bi_mkt, run_bi_fin, run_bi_rh, run_bi_sav]:
        all_domain_tests >> run_bi


warehouse_pipeline()
