{{ config(tags=['staging', 'wms']) }}

select
    cast(id                                                                    as varchar)       as id_location,
    cast(''                                                                    as varchar)       as code,
    cast(''                                                                    as varchar)       as label,
    cast(coalesce(argMax(zone,          _airbyte_extracted_at), '')            as varchar)       as zone,
    cast(coalesce(argMax(aisle,         _airbyte_extracted_at), '')            as varchar)       as aisle,
    cast(coalesce(argMax(rack,          _airbyte_extracted_at), '')            as varchar)       as rack,
    cast(coalesce(argMax(level,         _airbyte_extracted_at), '')            as varchar)       as level,
    cast(coalesce(argMax(bin_slot,      _airbyte_extracted_at), '')            as varchar)       as position,
    cast(coalesce(argMax(warehouse_ref, _airbyte_extracted_at), '')            as varchar)       as warehouse_id,
    cast(coalesce(argMax(location_type, _airbyte_extracted_at), '')            as varchar)       as location_type,
    cast(coalesce(argMax(capacity_units,_airbyte_extracted_at), 0)             as decimal(18,2)) as max_weight_kg,
    cast(coalesce(argMax(is_active,     _airbyte_extracted_at), false)         as boolean)       as is_active,
    cast(argMax(created_at,             _airbyte_extracted_at)                 as timestamp)     as created_at,
    cast(null                                                                  as Nullable(DateTime64(3))) as updated_at,
    cast(max(_airbyte_extracted_at)                                            as timestamp)     as _etl_loaded_at
from {{ source('wms', 'locations') }}
where id is not null
group by id
