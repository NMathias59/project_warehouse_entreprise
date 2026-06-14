{{ config(tags=['staging', 'plm']) }}

with source as (

    select * from {{ source('plm', 'products') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(code,              _airbyte_extracted_at) as code,
        argMax(name,              _airbyte_extracted_at) as name,
        argMax(description,       _airbyte_extracted_at) as description,
        argMax(product_family,    _airbyte_extracted_at) as product_family,
        argMax(lifecycle_status,  _airbyte_extracted_at) as lifecycle_status,
        argMax(responsible_id,    _airbyte_extracted_at) as responsible_id,
        argMax(launch_date,       _airbyte_extracted_at) as launch_date,
        argMax(end_of_life_date,  _airbyte_extracted_at) as end_of_life_date,
        argMax(created_at,        _airbyte_extracted_at) as created_at,
        argMax(updated_at,        _airbyte_extracted_at) as updated_at,
        max(_airbyte_extracted_at)                       as latest_extracted_at
    from source
    group by id

)

select
    cast(id                               as varchar)   as id_product,
    cast(coalesce(code, '')               as varchar)   as code,
    cast(coalesce(name, '')               as varchar)   as name,
    cast(coalesce(description, '')        as varchar)   as description,
    cast(coalesce(product_family, '')     as varchar)   as product_family,
    cast(coalesce(lifecycle_status, '')   as varchar)   as lifecycle_status,
    cast(coalesce(responsible_id, '')     as varchar)   as responsible_id,
    cast(launch_date                      as date)      as launch_date,
    cast(end_of_life_date                 as date)      as end_of_life_date,
    cast(created_at                       as timestamp) as created_at,
    toDateTimeOrNull(toString(updated_at))              as updated_at,
    cast(latest_extracted_at              as timestamp) as _etl_loaded_at
from deduped
