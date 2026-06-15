{{ config(tags=['staging', 'qms']) }}

with source as (

    select * from {{ source('qms', 'non_conformities') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(nc_number,    _airbyte_extracted_at) as reference,
        argMax(description,  _airbyte_extracted_at) as description,
        argMax(`source`,     _airbyte_extracted_at) as nc_type,
        argMax(severity,     _airbyte_extracted_at) as severity,
        argMax(product_sku,  _airbyte_extracted_at) as product_id,
        argMax(status,       _airbyte_extracted_at) as status,
        argMax(detected_at,  _airbyte_extracted_at) as detected_at,
        argMax(closed_at,    _airbyte_extracted_at) as closed_at,
        max(_airbyte_extracted_at)                  as latest_extracted_at
    from source
    group by id

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
    cast(latest_extracted_at              as timestamp) as _etl_loaded_at
from deduped
