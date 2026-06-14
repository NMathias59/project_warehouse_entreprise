{{ config(tags=['staging', 'plm']) }}

with source as (

    select * from {{ source('plm', 'bom_headers') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(product_version_id,  _airbyte_extracted_at) as product_version_id,
        argMax(bom_type,            _airbyte_extracted_at) as bom_type,
        argMax(status,              _airbyte_extracted_at) as status,
        argMax(total_components,    _airbyte_extracted_at) as total_components,
        argMax(created_at,          _airbyte_extracted_at) as created_at,
        argMax(updated_at,          _airbyte_extracted_at) as updated_at,
        max(_airbyte_extracted_at)                         as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                    as varchar)   as id_bom_header,
    cast(coalesce(product_version_id, '')      as varchar)   as product_version_id,
    cast(coalesce(bom_type, '')                as varchar)   as bom_type,
    cast(coalesce(status, '')                  as varchar)   as status,
    coalesce(total_components, 0)                            as total_components,
    cast(created_at                            as timestamp) as created_at,
    toDateTimeOrNull(toString(updated_at))                   as updated_at,
    cast(latest_extracted_at                   as timestamp) as _etl_loaded_at
from deduped
