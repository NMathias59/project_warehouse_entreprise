{{ config(tags=['staging', 'crm']) }}

-- Déduplication via argMax — même pattern que stg_crm__accounts.

with source as (

    select * from {{ source('crm', 'contacts') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(first_name,          _airbyte_extracted_at) as first_name,
        argMax(last_name,           _airbyte_extracted_at) as last_name,
        argMax(email,               _airbyte_extracted_at) as email,
        argMax(phone,               _airbyte_extracted_at) as phone,
        argMax(role,                _airbyte_extracted_at) as role,
        argMax(is_primary,          _airbyte_extracted_at) as is_primary,
        argMax(account_id,          _airbyte_extracted_at) as account_id,
        argMax(source_customer_id,  _airbyte_extracted_at) as source_customer_id,
        argMax(source_supplier_id,  _airbyte_extracted_at) as source_supplier_id,
        argMax(created_at,          _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                         as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                  as varchar)   as id_contact,
    cast(coalesce(first_name, '')            as varchar)   as first_name,
    cast(coalesce(last_name, '')             as varchar)   as last_name,
    cast(coalesce(email, '')                 as varchar)   as email,
    cast(coalesce(phone, '')                 as varchar)   as phone,
    cast(coalesce(role, '')                  as varchar)   as role,
    cast(coalesce(is_primary, false)         as boolean)   as is_primary,
    cast(coalesce(account_id, '')            as varchar)   as account_id,
    cast(coalesce(source_customer_id, '')    as varchar)   as source_customer_id,
    cast(coalesce(source_supplier_id, '')    as varchar)   as source_supplier_id,
    cast(created_at                          as timestamp) as created_at,
    cast(latest_extracted_at                 as timestamp) as _etl_loaded_at
from deduped
