{{ config(tags=['staging', 'plm']) }}

with source as (

    select * from {{ source('plm', 'bom_headers') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(product_revision_id, _airbyte_extracted_at) as product_version_id,
        argMax(status,              _airbyte_extracted_at) as status,
        argMax(created_at,          _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                         as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                    as varchar)   as id_bom_header,
    cast(coalesce(product_version_id, '')      as varchar)   as product_version_id,
    cast(''                                    as varchar)   as bom_type,
    cast(coalesce(status, '')                  as varchar)   as status,
    0                                                        as total_components,
    cast(created_at                            as timestamp) as created_at,
    cast(null as Nullable(DateTime64(3)))                    as updated_at,
    cast(latest_extracted_at                   as timestamp) as _etl_loaded_at
from deduped
