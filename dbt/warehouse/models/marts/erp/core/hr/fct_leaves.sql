{{
    config(
        materialized='incremental',
        unique_key='id_leave',
        incremental_strategy='append',
        tags=['core', 'erp', 'fct', 'hr'],
        pre_hook=[
            "{{ clickhouse_delete_existing_rows(ref('stg_erp__leaves'), 'id_leave', 'id_leave', 'starts_at', 7) }}"
        ]
    )
}}

select
    id_leave,
    employee_id,
    leave_type_id,
    starts_at,
    ends_at,
    status 
from {{ ref('stg_erp__leaves') }}

{% if is_incremental() %}
where starts_at > (select coalesce(max(starts_at), '1970-01-01') from {{ this }})
{% endif %}