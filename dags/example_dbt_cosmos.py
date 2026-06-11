# Exemple DAG Cosmos — non utilisé en production (voir warehouse_pipeline.py).
from datetime import datetime

from cosmos import DbtDag, ProjectConfig, ProfileConfig

from include.constants import warehouse_path, venv_execution_config

dbt_cosmos_dag = DbtDag(
    project_config=ProjectConfig(warehouse_path),
    profile_config=ProfileConfig(
        profile_name="warehouse",
        target_name="erp",
        profiles_yml_filepath=warehouse_path / "profiles.yml",
    ),
    execution_config=venv_execution_config,
    schedule="@daily",
    start_date=datetime(2025, 4, 1),
    dag_id="example_dbt_cosmos",
    is_paused_upon_creation=True,
    default_args={"retries": 2},
)
