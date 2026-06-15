{{ config(tags=['staging', 'wms']) }}

with base as (

    select * from {{ ref('base_wms__locations') }}

)

select
    cast(id                                        as varchar)       as id_location,
    cast(''                                        as varchar)       as code,
    cast(''                                        as varchar)       as label,
    cast(coalesce(zone,          '')               as varchar)       as zone,
    cast(coalesce(aisle,         '')               as varchar)       as aisle,
    cast(coalesce(rack,          '')               as varchar)       as rack,
    cast(coalesce(level,         '')               as varchar)       as level,
    cast(coalesce(bin_slot,      '')               as varchar)       as position,
    cast(coalesce(warehouse_ref, '')               as varchar)       as warehouse_id,
    cast(coalesce(location_type, '')               as varchar)       as location_type,
    cast(coalesce(capacity_units,0)                as decimal(18,2)) as max_weight_kg,
    cast(coalesce(is_active,     false)            as boolean)       as is_active,
    cast(created_at                                as timestamp)     as created_at,
    cast(null as Nullable(DateTime64(3)))                            as updated_at,
    cast(latest_extracted_at                as timestamp)     as _etl_loaded_at
from base
