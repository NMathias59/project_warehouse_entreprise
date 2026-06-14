{{ config(tags=['staging', 'plm']) }}

with source as (

    select * from {{ source('plm', 'product_versions') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(product_id,       _airbyte_extracted_at) as product_id,
        argMax(version_number,   _airbyte_extracted_at) as version_number,
        argMax(status,           _airbyte_extracted_at) as status,
        argMax(change_summary,   _airbyte_extracted_at) as change_summary,
        argMax(approved_by,      _airbyte_extracted_at) as approved_by,
        argMax(approved_at,      _airbyte_extracted_at) as approved_at,
        argMax(effective_date,   _airbyte_extracted_at) as effective_date,
        argMax(created_at,       _airbyte_extracted_at) as created_at,
        argMax(updated_at,       _airbyte_extracted_at) as updated_at,
        max(_airbyte_extracted_at)                      as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                 as varchar)   as id_product_version,
    cast(coalesce(product_id, '')           as varchar)   as product_id,
    cast(coalesce(version_number, '')       as varchar)   as version_number,
    cast(coalesce(status, '')               as varchar)   as status,
    cast(coalesce(change_summary, '')       as varchar)   as change_summary,
    cast(coalesce(approved_by, '')          as varchar)   as approved_by,
    toDateTimeOrNull(toString(approved_at))               as approved_at,
    cast(effective_date                     as date)      as effective_date,
    cast(created_at                         as timestamp) as created_at,
    toDateTimeOrNull(toString(updated_at))                as updated_at,
    cast(latest_extracted_at                as timestamp) as _etl_loaded_at
from deduped
