{{ config(materialized='view', tags=['staging', 'wms']) }}

select
    id,
    argMax(zone,          _airbyte_extracted_at) as zone,
    argMax(aisle,         _airbyte_extracted_at) as aisle,
    argMax(rack,          _airbyte_extracted_at) as rack,
    argMax(level,         _airbyte_extracted_at) as level,
    argMax(bin_slot,      _airbyte_extracted_at) as bin_slot,
    argMax(warehouse_ref, _airbyte_extracted_at) as warehouse_ref,
    argMax(location_type, _airbyte_extracted_at) as location_type,
    argMax(capacity_units,_airbyte_extracted_at) as capacity_units,
    argMax(is_active,     _airbyte_extracted_at) as is_active,
    argMax(created_at,    _airbyte_extracted_at) as created_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('wms', 'locations') }}
where id is not null
group by id
