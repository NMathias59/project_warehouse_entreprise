{{ config(materialized='incremental', unique_key='id_stock_movement', incremental_strategy='append', tags=['mart','erp','core'],
           pre_hook=[ clickhouse_delete_existing_rows(ref('stg_erp__component_stock_movements'), 'id_component_stock_movement', 'id_stock_movement', 'moved_at', 7) ]) }}
{# clickhouse detected: 'merge' strategy may not be supported by the ClickHouse adapter.
   Using 'append' as a compatible incremental strategy. If updates must be applied, implement a
   delete+insert or dedup strategy appropriate for your adapter. #}

select
    id_component_stock_movement as id_stock_movement,
    type as movement_type,
    component_id,
    quantity,
    location_id,
    moved_at as created_at,
    reference
from {{ ref('stg_erp__component_stock_movements') }}

{% if is_incremental() %}
where moved_at > (select coalesce(max(moved_at), '1970-01-01') from {{ this }})
{% endif %}