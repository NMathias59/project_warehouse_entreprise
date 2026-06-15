{{ config(tags=['staging', 'plm']) }}

with source as (

    select * from {{ source('plm', 'change_requests') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(eco_number,           _airbyte_extracted_at) as reference,
        argMax(title,                _airbyte_extracted_at) as title,
        argMax(description,          _airbyte_extracted_at) as description,
        argMax(product_id,           _airbyte_extracted_at) as product_id,
        argMax(priority,             _airbyte_extracted_at) as priority,
        argMax(status,               _airbyte_extracted_at) as status,
        argMax(requested_by,         _airbyte_extracted_at) as requested_by,
        argMax(approved_by,          _airbyte_extracted_at) as approved_by,
        argMax(implementation_date,  _airbyte_extracted_at) as implemented_at,
        argMax(created_at,           _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                          as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                   as varchar)   as id_change_request,
    cast(coalesce(reference, '')              as varchar)   as reference,
    cast(coalesce(title, '')                  as varchar)   as title,
    cast(coalesce(description, '')            as varchar)   as description,
    cast(coalesce(product_id, '')             as varchar)   as product_id,
    cast(''                                   as varchar)   as change_type,
    cast(coalesce(priority, '')               as varchar)   as priority,
    cast(coalesce(status, '')                 as varchar)   as status,
    cast(coalesce(requested_by, '')           as varchar)   as requested_by,
    cast(coalesce(approved_by, '')            as varchar)   as approved_by,
    cast(created_at                           as timestamp) as submitted_at,
    cast(null as Nullable(DateTime64(3)))                   as approved_at,
    toDateTimeOrNull(toString(implemented_at))              as implemented_at,
    cast(created_at                           as timestamp) as created_at,
    cast(null as Nullable(DateTime64(3)))                   as updated_at,
    cast(latest_extracted_at                  as timestamp) as _etl_loaded_at
from deduped
