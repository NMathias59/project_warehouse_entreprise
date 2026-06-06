{{ config(materialized='incremental', unique_key='status', incremental_strategy='append', tags=['mart', 'erp', 'core', 'procurement'],
           pre_hook=[ clickhouse_delete_existing_rows(ref('stg_erp__purchase_orders'), 'status', 'status', 'updated_at', 7) ]) }}

{# ClickHouse incremental strategy: delete recent source keys first, then append the recomputed aggregates. #}

select
    status,
    nb_orders,
    total_ht
from {{ ref('int_erp__purchase_order_status_stats') }}

{% if is_incremental() %}
where 1 = 1
{% endif %}

