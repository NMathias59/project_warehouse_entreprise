{{ config(tags=['staging', 'qms']) }}

with base as (

    select * from {{ ref('base_qms__non_conformities') }}

)

select
    cast(id                               as varchar)   as id_non_conformity,
    cast(coalesce(reference, '')          as varchar)   as reference,
    cast(''                               as varchar)   as title,
    cast(coalesce(description, '')        as varchar)   as description,
    cast(coalesce(nc_type, '')            as varchar)   as nc_type,
    cast(coalesce(severity, '')           as varchar)   as severity,
    cast(coalesce(nc_type, '')            as varchar)   as source,
    cast(coalesce(product_id, '')         as varchar)   as product_id,
    cast(''                               as varchar)   as supplier_id,
    cast(coalesce(status, '')             as varchar)   as status,
    cast(''                               as varchar)   as detected_by,
    cast(detected_at                      as timestamp) as detected_at,
    toDateTimeOrNull(toString(closed_at))               as closed_at,
    cast(null as Nullable(DateTime64(3)))               as created_at,
    cast(null as Nullable(DateTime64(3)))               as updated_at,
    cast(latest_extracted_at                as timestamp) as _etl_loaded_at
from base
