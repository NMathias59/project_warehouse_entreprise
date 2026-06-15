{{ config(tags=['staging', 'wms']) }}

with base as (

    select * from {{ ref('base_wms__inventory_adjustments') }}

)

select
    cast(id                                                            as varchar)       as id_inventory_adjustment,
    cast(coalesce(session_id,    '')                                   as varchar)       as reference,
    cast('cycle_count'                                                 as varchar)       as adjustment_type,
    cast(coalesce(product_sku,   '')                                   as varchar)       as product_id,
    cast(coalesce(location_id,   '')                                   as varchar)       as location_id,
    cast(''                                                            as varchar)       as warehouse_id,
    cast(coalesce(qty_system,    0)                                    as decimal(18,2)) as quantity_before,
    cast(coalesce(qty_counted,   0)                                    as decimal(18,2)) as quantity_after,
    cast(coalesce(variance,      0)                                    as decimal(18,2)) as delta_quantity,
    cast(''                                                            as varchar)       as reason,
    cast(''                                                            as varchar)       as adjusted_by,
    toDateTimeOrNull(toString(counted_at))                                               as adjusted_at,
    cast(latest_extracted_at                as timestamp)     as created_at,
    cast(latest_extracted_at                as timestamp)     as _etl_loaded_at
from base
