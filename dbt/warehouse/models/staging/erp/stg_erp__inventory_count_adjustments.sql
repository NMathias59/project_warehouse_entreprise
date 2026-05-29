{{ config(tags=['staging', 'erp']) }}

with source as (
    select * from {{ source('erp', 'inventory_count_adjustments') }}
)

select
    cast(id as varchar)                        as id_inventory_count_adjustment,
    cast(inventory_count_id as varchar)        as inventory_count_id,
    cast(component_id as varchar)              as component_id,
    cast(location_id as varchar)               as location_id,
    cast(reason as varchar)                    as reason,
    cast(variance_qty as int)                  as variance_qty,
    cast(validated_at as timestamp)            as validated_at,
    cast(validated_by as varchar)              as validated_by,
    cast(_ab_cdc_updated_at as varchar)        as updated_at
from source
where id is not null
