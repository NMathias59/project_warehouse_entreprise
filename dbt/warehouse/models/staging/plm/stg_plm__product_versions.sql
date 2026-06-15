{{ config(tags=['staging', 'plm']) }}

with source as (

    select * from {{ source('plm', 'product_versions') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(product_id,     _airbyte_extracted_at) as product_id,
        argMax(revision,       _airbyte_extracted_at) as version_number,
        argMax(status,         _airbyte_extracted_at) as status,
        argMax(reason,         _airbyte_extracted_at) as change_summary,
        argMax(approved_by,    _airbyte_extracted_at) as approved_by,
        argMax(revision_date,  _airbyte_extracted_at) as effective_date,
        argMax(created_at,     _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                    as latest_extracted_at
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
    cast(null as Nullable(DateTime64(3)))                 as approved_at,
    cast(effective_date                     as date)      as effective_date,
    cast(created_at                         as timestamp) as created_at,
    cast(null as Nullable(DateTime64(3)))                 as updated_at,
    cast(latest_extracted_at                as timestamp) as _etl_loaded_at
from deduped
