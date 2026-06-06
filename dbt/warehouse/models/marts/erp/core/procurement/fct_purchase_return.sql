{{ config(
    materialized='incremental',
    unique_key='id_purchase_return',
    incremental_strategy='append',
    on_schema_change='sync_all_columns',
    tags=['mart','erp','core','procurement'],
    pre_hook=[ clickhouse_delete_existing_rows(ref('stg_erp__purchase_returns'), 'id_purchase_return', 'id_purchase_return', 'created_at', 7) ]
) }}

{# Incremental ClickHouse: delete recent rows from the source window, then append the refreshed rows. #}

with pr as (
    select
        id_purchase_return,
        reference,
        created_at,
        supplier_id,
        purchase_order_id,
        0 as total_ht,
        status
    from {{ ref('stg_erp__purchase_returns') }}
)

select
    id_purchase_return,
    reference,
    created_at,
    supplier_id,
    purchase_order_id,
    status
    , total_ht
from pr

{% if is_incremental() %}
where created_at > (select coalesce(max(created_at), '1970-01-01') from {{ this }})
{% endif %}
