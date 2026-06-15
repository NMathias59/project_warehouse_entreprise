{{ config(tags=['staging', 'plm']) }}

with source as (

    select * from {{ source('plm', 'documents') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(product_id,      _airbyte_extracted_at) as product_id,
        argMax(doc_type,        _airbyte_extracted_at) as document_type,
        argMax(title,           _airbyte_extracted_at) as title,
        argMax(file_path,       _airbyte_extracted_at) as file_reference,
        argMax(current_version, _airbyte_extracted_at) as version,
        argMax(status,          _airbyte_extracted_at) as status,
        argMax(author,          _airbyte_extracted_at) as created_by,
        argMax(created_at,      _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                     as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                    as varchar)   as id_document,
    cast(coalesce(product_id, '')              as varchar)   as product_id,
    cast(''                                    as varchar)   as product_version_id,
    cast(coalesce(document_type, '')           as varchar)   as document_type,
    cast(coalesce(title, '')                   as varchar)   as title,
    cast(coalesce(file_reference, '')          as varchar)   as file_reference,
    cast(coalesce(version, '')                 as varchar)   as version,
    cast(coalesce(status, '')                  as varchar)   as status,
    cast(coalesce(created_by, '')              as varchar)   as created_by,
    cast(''                                    as varchar)   as approved_by,
    cast(created_at                            as timestamp) as created_at,
    cast(null as Nullable(DateTime64(3)))                    as updated_at,
    cast(latest_extracted_at                   as timestamp) as _etl_loaded_at
from deduped
