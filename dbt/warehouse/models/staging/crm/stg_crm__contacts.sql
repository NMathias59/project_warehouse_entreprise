{{ config(tags=['staging', 'crm']) }}

select
    cast(id                                  as varchar)   as id_contact,
    cast(coalesce(first_name, '')            as varchar)   as first_name,
    cast(coalesce(last_name, '')             as varchar)   as last_name,
    cast(coalesce(email, '')                 as varchar)   as email,
    cast(coalesce(phone, '')                 as varchar)   as phone,
    cast(coalesce(role, '')                  as varchar)   as role,
    cast(is_primary                          as boolean)   as is_primary,
    cast(coalesce(account_id, '')            as varchar)   as account_id,
    cast(coalesce(source_customer_id, '')    as varchar)   as source_customer_id,
    cast(coalesce(source_supplier_id, '')    as varchar)   as source_supplier_id,
    cast(created_at                          as timestamp) as created_at,
    cast(_airbyte_extracted_at               as timestamp) as _etl_loaded_at
from {{ source('crm', 'contacts') }}
where id is not null
