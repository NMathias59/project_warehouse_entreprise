{{ config(tags=['staging', 'plm']) }}

with base as (

    select * from {{ ref('base_plm__documents') }}

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
    cast(latest_extracted_at                as timestamp) as _etl_loaded_at
from base
