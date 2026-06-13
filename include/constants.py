"Contains constants used in the DAGs"

import os
from pathlib import Path

from cosmos import ExecutionConfig

# ── dbt / Warehouse ───────────────────────────────────────────────────────────
warehouse_path = Path("/usr/local/airflow/dbt/warehouse")
dbt_executable = Path("/usr/local/airflow/dbt_venv/bin/dbt")

venv_execution_config = ExecutionConfig(
    dbt_executable_path=str(dbt_executable),
)

# ── Raccourcis string pour BashOperator ───────────────────────────────────────
WAREHOUSE_DIR = str(warehouse_path)
DBT_BIN       = str(dbt_executable)

# ── Sélecteurs dbt — couche warehouse (par domaine source) ────────────────────
# Les ephemeral (intermediate) sont inlinés automatiquement.
# Les reports sont groupés avec leur domaine (rpt_erp_* ne touche que marts/erp).

DBT_SELECT_ERP = (
    "path:models/staging/erp "
    "path:models/marts/erp "
    "path:models/reports/erp"
)

DBT_SELECT_CRM = (
    "path:models/staging/crm "
    "path:models/marts/crm "
    "path:models/reports/crm"
)

DBT_SELECT_MKT = (
    "path:models/staging/market_place "
    "path:models/marts/market_place "
    "path:models/reports/market_place"
)

# ── Sélecteurs dbt — BI datamarts (par domaine métier) ────────────────────────
# Note : BI_LOGISTIQUE dépend de BI_PRODUCTION (bi_log__shortage_coverage
# référence bi_prod__bom_vs_stock via ref()). Dans le DAG, BI_LOGISTIQUE
# attend donc la fin du test BI_PRODUCTION avant de démarrer.

DBT_SELECT_BI_PRODUCTION  = "path:models/marts/BI_PRODUCTION"
DBT_SELECT_BI_LOGISTIQUE  = "path:models/marts/BI_LOGISTIQUE"
DBT_SELECT_BI_MARKETING   = "path:models/marts/BI_MARKETING"
DBT_SELECT_BI_FINANCE     = "path:models/marts/BI_FINANCE"
DBT_SELECT_BI_RH          = "path:models/marts/BI_RH"
DBT_SELECT_BI_SAV         = "path:models/marts/BI_SAV"

# ── URL + Auth Airbyte OSS (abctl / Kubernetes) ───────────────────────────────
# Credentials et UUIDs chargés depuis .env (voir .env.example).
AIRBYTE_API_URL       = "http://host.docker.internal:8000"
AIRBYTE_CLIENT_ID     = os.environ["AIRBYTE_CLIENT_ID"]
AIRBYTE_CLIENT_SECRET = os.environ["AIRBYTE_CLIENT_SECRET"]

# ── UUIDs des connexions Airbyte ──────────────────────────────────────────────
AIRBYTE_CONN_ERP = os.environ["AIRBYTE_CONN_ERP"]
AIRBYTE_CONN_CRM = os.environ["AIRBYTE_CONN_CRM"]
AIRBYTE_CONN_MKT = os.environ["AIRBYTE_CONN_MKT"]
