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
# Les intermédiaires sont des views (plus ephemeral) → doivent être inclus
# explicitement dans le --select pour être créés avant les marts.

DBT_SELECT_ERP         = "path:models/staging/erp path:models/intermediate/erp path:models/marts/erp"
DBT_SELECT_CRM         = "path:models/staging/crm path:models/intermediate/crm path:models/marts/crm"
DBT_SELECT_MKT         = "path:models/staging/market_place path:models/intermediate/market_place path:models/marts/market_place"
DBT_SELECT_WMS         = "path:models/staging/wms path:models/intermediate/wms path:models/marts/wms"
DBT_SELECT_MES         = "path:models/staging/mes path:models/intermediate/mes path:models/marts/mes"
DBT_SELECT_MARKETING   = "path:models/staging/marketing path:models/intermediate/marketing path:models/marts/marketing"
DBT_SELECT_SAV         = "path:models/staging/sav path:models/intermediate/sav path:models/marts/sav"
DBT_SELECT_PLM         = "path:models/staging/plm path:models/intermediate/plm path:models/marts/plm"
DBT_SELECT_SIRH        = "path:models/staging/sirh path:models/intermediate/sirh path:models/marts/sirh"
DBT_SELECT_QMS         = "path:models/staging/qms path:models/intermediate/qms path:models/marts/qms"
DBT_SELECT_FINANCE     = "path:models/staging/finance path:models/intermediate/finance path:models/marts/finance"
DBT_SELECT_PROCUREMENT = "path:models/staging/procurement path:models/intermediate/procurement path:models/marts/procurement"

# ── Sélecteurs dbt — BI datamarts (par domaine métier) ────────────────────────
# BI_LOGISTIQUE dépend de BI_PRODUCTION (bi_log__shortage_coverage ref()
# bi_prod__bom_vs_stock) → BI_LOGISTIQUE attend test_bi_production dans le DAG.

DBT_SELECT_BI_PRODUCTION  = "path:models/marts/BI_PRODUCTION"
DBT_SELECT_BI_LOGISTIQUE  = "path:models/marts/BI_LOGISTIQUE"
DBT_SELECT_BI_MARKETING   = "path:models/marts/BI_MARKETING"
DBT_SELECT_BI_FINANCE     = "path:models/marts/BI_FINANCE"
DBT_SELECT_BI_RH          = "path:models/marts/BI_RH"
DBT_SELECT_BI_SAV         = "path:models/marts/BI_SAV"
DBT_SELECT_BI_COMMERCIAL  = "path:models/marts/BI_COMMERCIAL"
DBT_SELECT_BI_ACHATS      = "path:models/marts/BI_ACHATS"
DBT_SELECT_BI_QUALITE     = "path:models/marts/BI_QUALITE"
DBT_SELECT_BI_PRODUIT     = "path:models/marts/BI_PRODUIT"

# ── URL + Auth Airbyte OSS (abctl / Kubernetes) ───────────────────────────────
# Credentials chargés depuis .env (voir .env.example).
AIRBYTE_API_URL       = "http://host.docker.internal:8000"
AIRBYTE_CLIENT_ID     = os.environ["AIRBYTE_CLIENT_ID"]
AIRBYTE_CLIENT_SECRET = os.environ["AIRBYTE_CLIENT_SECRET"]

# ── UUIDs des connexions Airbyte ──────────────────────────────────────────────
# Domaines initiaux — obligatoires (le scheduler crashe si absents).
AIRBYTE_CONN_ERP = os.environ["AIRBYTE_CONN_ERP"]
AIRBYTE_CONN_CRM = os.environ["AIRBYTE_CONN_CRM"]
AIRBYTE_CONN_MKT = os.environ["AIRBYTE_CONN_MKT"]

# Nouveaux domaines — optionnels : None si la connexion Airbyte n'est pas encore
# créée. Le DAG tourne quand même (dbt s'exécute, les sources seront vides).
AIRBYTE_CONN_WMS         = os.environ.get("AIRBYTE_CONN_WMS")
AIRBYTE_CONN_MES         = os.environ.get("AIRBYTE_CONN_MES")
AIRBYTE_CONN_MARKETING   = os.environ.get("AIRBYTE_CONN_MARKETING")
AIRBYTE_CONN_SAV         = os.environ.get("AIRBYTE_CONN_SAV")
AIRBYTE_CONN_PLM         = os.environ.get("AIRBYTE_CONN_PLM")
AIRBYTE_CONN_SIRH        = os.environ.get("AIRBYTE_CONN_SIRH")
AIRBYTE_CONN_QMS         = os.environ.get("AIRBYTE_CONN_QMS")
AIRBYTE_CONN_FINANCE     = os.environ.get("AIRBYTE_CONN_FINANCE")
AIRBYTE_CONN_PROCUREMENT = os.environ.get("AIRBYTE_CONN_PROCUREMENT")
