{{ config(
    materialized='incremental',
    unique_key='id_supplier_contract',
    incremental_strategy='append',
    on_schema_change='append_new_columns',
    tags=['mart','erp','core','procurement'],
    pre_hook=[ clickhouse_delete_existing_rows(ref('stg_erp__supplier_contracts'), 'id_supplier_contract', 'id_supplier_contract', 'created_at', 7) ]
) }}

{# Incremental ClickHouse: delete recent keys from the source window, then append refreshed rows. #}

with sc as (
    select
        id_supplier_contract,
        supplier_id,
        valid_from,
        valid_until,
        currency,
        0 as amount,
        true as is_active,
        created_at
    from {{ ref('stg_erp__supplier_contracts') }}
)

select
    id_supplier_contract,
    supplier_id,
    -- map staging valid_from/valid_until to starts_at/ends_at
    valid_from as starts_at,
    valid_until as ends_at,
    currency,
    -- amount not present in source, default to 0
    amount,
    -- is_active not present, default to true
    is_active
from sc

{% if is_incremental() %}
where valid_from > (select coalesce(max(t.starts_at), '1970-01-01') from {{ this }} as t)
{% endif %}
