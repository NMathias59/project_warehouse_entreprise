"""
Pipeline principal warehouse — déclenché chaque nuit à 3h.

─── Phase 1+2 : Sync Airbyte → dbt warehouse (12 domaines en parallèle) ────

  Domaines avec Airbyte configuré (AIRBYTE_CONN_* présent dans .env) :
    airbyte_trigger_<d> → airbyte_wait_<d> → dbt_run_<d> → dbt_test_<d>

  Domaines sans UUID Airbyte encore (.env absent) :
    dbt_run_<d> → dbt_test_<d>   (sources vides, tests passent quand même)

  Domaines couverts :
    erp · crm · mkt             (connexions Airbyte obligatoires)
    wms · mes · marketing · sav · plm · sirh · qms · finance · procurement
                                (connexions optionnelles — see .env.example)

  Pattern Airbyte : trigger (PythonOperator, ~1 s, retourne job_id via XCom)
                  + AirbyteSyncSensor (mode=reschedule, poke toutes les 30 s)
  → le worker slot est libéré entre chaque poke (pas de sleep() bloquant).

─── Phase 3 : BI datamarts — gatée sur les 12 dbt_test_ ─────────────────────

    ├─ dbt_run_bi_production → dbt_test_bi_production ─┐
    │                                                   └─► dbt_run_bi_logistique
    ├─ dbt_run_bi_marketing  → dbt_test_bi_marketing
    ├─ dbt_run_bi_finance    → dbt_test_bi_finance
    ├─ dbt_run_bi_rh         → dbt_test_bi_rh
    └─ dbt_run_bi_sav        → dbt_test_bi_sav

  bi_log__shortage_coverage ref() bi_prod__bom_vs_stock
  → BI_LOGISTIQUE démarre après dbt_test_bi_production uniquement.

─── Notifications ────────────────────────────────────────────────────────────

  on_failure_callback sur toutes les tâches — simulée par défaut (log Airflow).
  Voir _on_failure_callback() pour brancher Slack / email / Teams.

─── Config ───────────────────────────────────────────────────────────────────

  Credentials Airbyte + UUIDs des connexions : .env (voir .env.example).
  Auth : OAuth2 client_credentials (AIRBYTE_CLIENT_ID / AIRBYTE_CLIENT_SECRET).
  Constantes dbt/Airbyte centralisées dans include/constants.py.
"""

from __future__ import annotations

from datetime import datetime, timedelta

import requests

from airflow.decorators import dag
from airflow.exceptions import AirflowException
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.sensors.base import BaseSensorOperator

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


# ─── Notification ─────────────────────────────────────────────────────────────

def _on_failure_callback(context: dict) -> None:
    """
    Notification de panne — simulée par défaut (log Airflow uniquement).

    Pour activer une vraie alerte, remplacer le bloc TODO par :

      Slack  → requests.post(os.environ["SLACK_WEBHOOK_URL"],
                             json={"text": msg}, timeout=10)

      Email  → from airflow.utils.email import send_email
               send_email(to=["data-team@company.com"],
                          subject=f"[Airflow] {dag_id} › {task_id} FAILED",
                          html_content=msg)

      Teams  → requests.post(os.environ["TEAMS_WEBHOOK_URL"],
                             json={"text": msg}, timeout=10)
    """
    ti      = context["task_instance"]
    dag_id  = context["dag"].dag_id
    task_id = ti.task_id
    run_id  = context.get("run_id", "?")
    exc     = str(context.get("exception", "–"))[:400]

    msg = (
        f"[ALERT] DAG={dag_id} | TASK={task_id} | RUN={run_id} "
        f"| ERROR={exc} | LOG={ti.log_url}"
    )

    # TODO: remplacer ces deux lignes par l'appel au vrai notifier ci-dessus
    ti.log.error("FAILURE NOTIFICATION (simulated) — %s", msg)
    print(msg)


# ─── Airbyte helpers ──────────────────────────────────────────────────────────

_TERMINAL_STATUSES = {"succeeded", "failed", "cancelled", "incomplete"}


def _get_airbyte_token() -> str:
    resp = requests.post(
        f"{AIRBYTE_API_URL}/api/v1/applications/token",
        json={
            "client_id":     AIRBYTE_CLIENT_ID,
            "client_secret": AIRBYTE_CLIENT_SECRET,
            "grant_type":    "client_credentials",
        },
        timeout=30,
    )
    resp.raise_for_status()
    return resp.json()["access_token"]


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


def _trigger_airbyte_sync(connection_id: str) -> str:
    """
    Déclenche une sync Airbyte et retourne le job_id (rapide, sans polling).
    Gère le 409 : si un job tourne déjà, récupère son ID et le transmet au sensor.
    """
    token   = _get_airbyte_token()
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
            resp.raise_for_status()  # 409 sans job actif = erreur inattendue
    else:
        resp.raise_for_status()
        job_id = resp.json()["jobId"]

    return job_id


class AirbyteSyncSensor(BaseSensorOperator):
    """
    Sensor non-bloquant pour une sync Airbyte.

    mode='reschedule' : libère le worker slot entre chaque poke.
    Sans ça, 12 syncs parallèles bloqueraient 12 slots pendant des heures.
    """

    template_fields = ("job_id",)

    def __init__(self, *, job_id: str, **kwargs) -> None:
        super().__init__(mode="reschedule", poke_interval=30, **kwargs)
        self.job_id = job_id

    def poke(self, context: dict) -> bool:
        token = _get_airbyte_token()
        resp  = requests.get(
            f"{AIRBYTE_API_URL}/api/public/v1/jobs/{self.job_id}",
            headers={"Authorization": f"Bearer {token}"},
            timeout=30,
        )
        resp.raise_for_status()
        status = resp.json()["status"]
        if status == "succeeded":
            return True
        if status in _TERMINAL_STATUSES:
            raise AirflowException(
                f"Airbyte job {self.job_id} terminé en erreur : {status}"
            )
        return False


# ─── dbt helpers ──────────────────────────────────────────────────────────────

def _dbt(verb: str, select: str, target: str) -> str:
    return (
        f'cd {WAREHOUSE_DIR} '
        f'&& {DBT_BIN} {verb} --profiles-dir . --target {target} '
        f'--select "{select}"'
    )


def _dbt_domain(
    domain: str,
    select: str,
    target: str,
) -> tuple[BashOperator, BashOperator]:
    """Crée le couple (run, test) pour un domaine dbt. run >> test câblé en interne."""
    run = BashOperator(
        task_id=f"dbt_run_{domain}",
        bash_command=_dbt("run", select, target),
        retries=1,
        retry_delay=timedelta(minutes=2),
        execution_timeout=timedelta(hours=1),
    )
    test = BashOperator(
        task_id=f"dbt_test_{domain}",
        bash_command=_dbt("test", select, target),
        retries=0,
        execution_timeout=timedelta(minutes=30),
    )
    run >> test
    return run, test


def _domain_pipeline(
    domain: str,
    select: str,
    target: str,
    conn_id: str | None = None,
) -> tuple[BashOperator, BashOperator]:
    """
    Crée le pipeline complet d'un domaine :
      - Avec conn_id  : airbyte_trigger → airbyte_wait (sensor) → dbt_run → dbt_test
      - Sans conn_id  : dbt_run → dbt_test  (Airbyte pas encore configuré)

    Retourne (dbt_run, dbt_test) dans les deux cas.
    """
    run, test = _dbt_domain(domain, select, target)

    if conn_id:
        trigger = PythonOperator(
            task_id=f"airbyte_trigger_{domain}",
            python_callable=_trigger_airbyte_sync,
            op_kwargs={"connection_id": conn_id},
            retries=0,
            execution_timeout=timedelta(minutes=5),
        )
        sensor = AirbyteSyncSensor(
            task_id=f"airbyte_wait_{domain}",
            job_id=f"{{{{ task_instance.xcom_pull(task_ids='airbyte_trigger_{domain}') }}}}",
            execution_timeout=timedelta(hours=3),
        )
        trigger >> sensor >> run

    return run, test


# ─── DAG ──────────────────────────────────────────────────────────────────────

default_args: dict = {
    "owner":               "data-team",
    "retries":             0,
    "retry_delay":         timedelta(minutes=2),
    "email_on_failure":    False,
    "on_failure_callback": _on_failure_callback,
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
    _, test_erp = _domain_pipeline("erp", DBT_SELECT_ERP, "erp", AIRBYTE_CONN_ERP)
    _, test_crm = _domain_pipeline("crm", DBT_SELECT_CRM, "crm", AIRBYTE_CONN_CRM)
    _, test_mkt = _domain_pipeline("mkt", DBT_SELECT_MKT, "mkt", AIRBYTE_CONN_MKT)

    # Nouveaux domaines — sync Airbyte conditionnel (None si UUID absent du .env)
    _, test_wms         = _domain_pipeline("wms",         DBT_SELECT_WMS,         "wms",         AIRBYTE_CONN_WMS)
    _, test_mes         = _domain_pipeline("mes",         DBT_SELECT_MES,         "mes",         AIRBYTE_CONN_MES)
    _, test_marketing   = _domain_pipeline("marketing",   DBT_SELECT_MARKETING,   "marketing",   AIRBYTE_CONN_MARKETING)
    _, test_sav         = _domain_pipeline("sav",         DBT_SELECT_SAV,         "sav",         AIRBYTE_CONN_SAV)
    _, test_plm         = _domain_pipeline("plm",         DBT_SELECT_PLM,         "plm",         AIRBYTE_CONN_PLM)
    _, test_sirh        = _domain_pipeline("sirh",        DBT_SELECT_SIRH,        "sirh",        AIRBYTE_CONN_SIRH)
    _, test_qms         = _domain_pipeline("qms",         DBT_SELECT_QMS,         "qms",         AIRBYTE_CONN_QMS)
    _, test_finance     = _domain_pipeline("finance",     DBT_SELECT_FINANCE,     "finance",     AIRBYTE_CONN_FINANCE)
    _, test_procurement = _domain_pipeline("procurement", DBT_SELECT_PROCUREMENT, "procurement", AIRBYTE_CONN_PROCUREMENT)

    # ── Phase 3 : BI datamarts ────────────────────────────────────────────────
    # Condition d'entrée : les 12 tests domaines doivent être verts.
    all_domain_tests = [
        test_erp, test_crm, test_mkt,
        test_wms, test_mes, test_marketing, test_sav,
        test_plm, test_sirh, test_qms, test_finance, test_procurement,
    ]

    # BI_PRODUCTION — aucune dépendance BI croisée
    run_bi_prod, test_bi_prod = _dbt_domain("bi_production", DBT_SELECT_BI_PRODUCTION, "bi_production")
    all_domain_tests >> run_bi_prod

    # BI_LOGISTIQUE — dépend de BI_PRODUCTION (bi_log__shortage_coverage ref() bi_prod__bom_vs_stock)
    run_bi_log, _ = _dbt_domain("bi_logistique", DBT_SELECT_BI_LOGISTIQUE, "bi_logistique")
    test_bi_prod >> run_bi_log

    # BI_MARKETING, BI_FINANCE, BI_RH, BI_SAV — indépendants, parallèles
    run_bi_mkt, _ = _dbt_domain("bi_marketing", DBT_SELECT_BI_MARKETING, "bi_marketing")
    run_bi_fin, _ = _dbt_domain("bi_finance",   DBT_SELECT_BI_FINANCE,   "bi_finance")
    run_bi_rh,  _ = _dbt_domain("bi_rh",        DBT_SELECT_BI_RH,        "bi_rh")
    run_bi_sav, _ = _dbt_domain("bi_sav",       DBT_SELECT_BI_SAV,       "bi_sav")

    for run_bi in [run_bi_mkt, run_bi_fin, run_bi_rh, run_bi_sav]:
        all_domain_tests >> run_bi


warehouse_pipeline()
