{{ config(tags=['staging', 'procurement']) }}

with source as (

    select * from {{ source('procurement', 'supplier_contacts') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(supplier_id,  _airbyte_extracted_at) as supplier_id,
        argMax(first_name,   _airbyte_extracted_at) as first_name,
        argMax(last_name,    _airbyte_extracted_at) as last_name,
        argMax(email,        _airbyte_extracted_at) as email,
        argMax(phone,        _airbyte_extracted_at) as phone,
        argMax(role,         _airbyte_extracted_at) as role,
        argMax(is_primary,   _airbyte_extracted_at) as is_primary,
        argMax(created_at,   _airbyte_extracted_at) as created_at,
        argMax(updated_at,   _airbyte_extracted_at) as updated_at,
        max(_airbyte_extracted_at)                  as latest_extracted_at
    from source
    group by id

)

select
    cast(id                               as varchar)   as id_supplier_contact,
    cast(coalesce(supplier_id, '')        as varchar)   as supplier_id,
    cast(coalesce(first_name, '')         as varchar)   as first_name,
    cast(coalesce(last_name, '')          as varchar)   as last_name,
    cast(coalesce(email, '')              as varchar)   as email,
    cast(coalesce(phone, '')              as varchar)   as phone,
    cast(coalesce(role, '')               as varchar)   as role,
    cast(coalesce(is_primary, false)      as boolean)   as is_primary,
    cast(created_at                       as timestamp) as created_at,
    toDateTimeOrNull(toString(updated_at))              as updated_at,
    cast(latest_extracted_at              as timestamp) as _etl_loaded_at
from deduped
