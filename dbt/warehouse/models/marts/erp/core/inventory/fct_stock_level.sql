{{ config(materialized='incremental', unique_key='stock_id', incremental_strategy='append', tags=['mart','erp','core'],
           pre_hook=[ clickhouse_delete_existing_rows(ref('stg_erp__stock_levels'), 'id_stock_level', 'stock_id', 'updated_at', 7) ]) }}
{# clickhouse detected: 'merge' strategy may not be supported by the ClickHouse adapter.
   Using 'append' as a compatible incremental strategy. If updates must be applied, implement a
   delete+insert or dedup strategy appropriate for your adapter. #}

with sl as (
    select * from {{ ref('stg_erp__stock_levels') }}
),
cs as (
    select * from {{ ref('stg_erp__component_stock') }}
)

select
    coalesce(sl.id_stock_level, cs.id_component_stock) as stock_id,
    coalesce(sl.product_id, cs.component_id) as product_id,
    coalesce(sl.warehouse_id, cs.location_id) as location_id,
    coalesce(sl.quantity, cs.quantity) as quantity,
    coalesce(sl.updated_at, cs.updated_at) as updated_at
from sl
full outer join cs on sl.product_id = cs.component_id and sl.warehouse_id = cs.location_id

{% if is_incremental() %}
where coalesce(sl.updated_at, cs.updated_at) > (select coalesce(max(updated_at), '1970-01-01') from {{ this }})
{% endif %}
