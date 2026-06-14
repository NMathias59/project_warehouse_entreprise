{{ config(tags=['staging', 'wms']) }}

with source as (

    select * from {{ source('wms', 'locations') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(code,          _airbyte_extracted_at) as code,
        argMax(label,         _airbyte_extracted_at) as label,
        argMax(zone,          _airbyte_extracted_at) as zone,
        argMax(aisle,         _airbyte_extracted_at) as aisle,
        argMax(rack,          _airbyte_extracted_at) as rack,
        argMax(level,         _airbyte_extracted_at) as level,
        argMax(position,      _airbyte_extracted_at) as position,
        argMax(warehouse_id,  _airbyte_extracted_at) as warehouse_id,
        argMax(location_type, _airbyte_extracted_at) as location_type,
        argMax(max_weight_kg, _airbyte_extracted_at) as max_weight_kg,
        argMax(is_active,     _airbyte_extracted_at) as is_active,
        argMax(created_at,    _airbyte_extracted_at) as created_at,
        argMax(updated_at,    _airbyte_extracted_at) as updated_at,
        max(_airbyte_extracted_at)                   as latest_extracted_at
    from source
    group by id

)

select
    cast(id                              as varchar)       as id_location,
    cast(coalesce(code, '')              as varchar)       as code,
    cast(coalesce(label, '')             as varchar)       as label,
    cast(coalesce(zone, '')              as varchar)       as zone,
    cast(coalesce(aisle, '')             as varchar)       as aisle,
    cast(coalesce(rack, '')              as varchar)       as rack,
    cast(coalesce(level, '')             as varchar)       as level,
    cast(coalesce(position, '')          as varchar)       as position,
    cast(coalesce(warehouse_id, '')      as varchar)       as warehouse_id,
    cast(coalesce(location_type, '')     as varchar)       as location_type,
    cast(coalesce(max_weight_kg, 0)      as decimal(18,2)) as max_weight_kg,
    cast(coalesce(is_active, false)      as boolean)       as is_active,
    cast(created_at                      as timestamp)     as created_at,
    toDateTimeOrNull(toString(updated_at))                 as updated_at,
    cast(latest_extracted_at             as timestamp)     as _etl_loaded_at
from deduped
