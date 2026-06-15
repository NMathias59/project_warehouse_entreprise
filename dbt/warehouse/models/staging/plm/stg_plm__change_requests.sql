{{ config(tags=['staging', 'plm']) }}

with base as (

    select * from {{ ref('base_plm__change_requests') }}

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
    cast(latest_extracted_at                as timestamp) as _etl_loaded_at
from base
