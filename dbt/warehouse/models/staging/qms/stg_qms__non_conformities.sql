{{ config(tags=['staging', 'qms']) }}

with source as (

    select * from {{ source('qms', 'non_conformities') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(reference,    _airbyte_extracted_at) as reference,
        argMax(title,        _airbyte_extracted_at) as title,
        argMax(description,  _airbyte_extracted_at) as description,
        argMax(nc_type,      _airbyte_extracted_at) as nc_type,
        argMax(severity,     _airbyte_extracted_at) as severity,
        argMax(source,       _airbyte_extracted_at) as source,
        argMax(product_id,   _airbyte_extracted_at) as product_id,
        argMax(supplier_id,  _airbyte_extracted_at) as supplier_id,
        argMax(status,       _airbyte_extracted_at) as status,
        argMax(detected_by,  _airbyte_extracted_at) as detected_by,
        argMax(detected_at,  _airbyte_extracted_at) as detected_at,
        argMax(closed_at,    _airbyte_extracted_at) as closed_at,
        argMax(created_at,   _airbyte_extracted_at) as created_at,
        argMax(updated_at,   _airbyte_extracted_at) as updated_at,
        max(_airbyte_extracted_at)                  as latest_extracted_at
    from source
    group by id

)

select
    cast(id                               as varchar)   as id_non_conformity,
    cast(coalesce(reference, '')          as varchar)   as reference,
    cast(coalesce(title, '')              as varchar)   as title,
    cast(coalesce(description, '')        as varchar)   as description,
    cast(coalesce(nc_type, '')            as varchar)   as nc_type,
    cast(coalesce(severity, '')           as varchar)   as severity,
    cast(coalesce(source, '')             as varchar)   as source,
    cast(coalesce(product_id, '')         as varchar)   as product_id,
    cast(coalesce(supplier_id, '')        as varchar)   as supplier_id,
    cast(coalesce(status, '')             as varchar)   as status,
    cast(coalesce(detected_by, '')        as varchar)   as detected_by,
    cast(detected_at                      as timestamp) as detected_at,
    toDateTimeOrNull(toString(closed_at))               as closed_at,
    cast(created_at                       as timestamp) as created_at,
    toDateTimeOrNull(toString(updated_at))              as updated_at,
    cast(latest_extracted_at              as timestamp) as _etl_loaded_at
from deduped
