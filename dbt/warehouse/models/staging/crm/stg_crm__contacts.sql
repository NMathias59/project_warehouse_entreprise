{{ config(tags=['staging', 'crm']) }}

-- Déduplication via argMax — même pattern que stg_crm__accounts.

with base as (

    select * from {{ ref('base_crm__contacts') }}

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
    cast(latest_extracted_at                as timestamp) as _etl_loaded_at
from base
