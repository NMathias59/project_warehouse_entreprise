{{ config(tags=['staging', 'procurement']) }}

with source as (

    select * from {{ source('procurement', 'suppliers') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(code,               _airbyte_extracted_at) as code,
        argMax(name,               _airbyte_extracted_at) as name,
        argMax(supplier_type,      _airbyte_extracted_at) as supplier_type,
        argMax(status,             _airbyte_extracted_at) as status,
        argMax(country_code,       _airbyte_extracted_at) as country_code,
        argMax(city,               _airbyte_extracted_at) as city,
        argMax(payment_terms_id,   _airbyte_extracted_at) as payment_terms_id,
        argMax(currency,           _airbyte_extracted_at) as currency,
        argMax(tax_id,             _airbyte_extracted_at) as tax_id,
        argMax(is_active,          _airbyte_extracted_at) as is_active,
        argMax(created_at,         _airbyte_extracted_at) as created_at,
        argMax(updated_at,         _airbyte_extracted_at) as updated_at,
        max(_airbyte_extracted_at)                        as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                  as varchar)   as id_supplier,
    cast(coalesce(code, '')                  as varchar)   as code,
    cast(coalesce(name, '')                  as varchar)   as name,
    cast(coalesce(supplier_type, '')         as varchar)   as supplier_type,
    cast(coalesce(status, '')                as varchar)   as status,
    cast(coalesce(country_code, '')          as varchar)   as country_code,
    cast(coalesce(city, '')                  as varchar)   as city,
    cast(coalesce(payment_terms_id, '')      as varchar)   as payment_terms_id,
    cast(coalesce(currency, '')              as varchar)   as currency,
    cast(coalesce(tax_id, '')                as varchar)   as tax_id,
    cast(coalesce(is_active, false)          as boolean)   as is_active,
    cast(created_at                          as timestamp) as created_at,
    toDateTimeOrNull(toString(updated_at))                 as updated_at,
    cast(latest_extracted_at                 as timestamp) as _etl_loaded_at
from deduped
