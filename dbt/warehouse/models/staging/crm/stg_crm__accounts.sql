{{ config(tags=['staging', 'crm']) }}

select
    cast(id                                    as varchar)       as id_account,
    cast(coalesce(name, '')                    as varchar)       as name,
    cast(coalesce(account_type, '')            as varchar)       as account_type,
    cast(coalesce(status, '')                  as varchar)       as status,
    cast(coalesce(segment, '')                 as varchar)       as segment,
    cast(coalesce(email, '')                   as varchar)       as email,
    cast(coalesce(phone, '')                   as varchar)       as phone,
    cast(coalesce(website, '')                 as varchar)       as website,
    cast(coalesce(city, '')                    as varchar)       as city,
    cast(coalesce(country_code, '')            as varchar)       as country_code,
    cast(coalesce(external_ref, '')            as varchar)       as external_ref,
    cast(coalesce(source_customer_id, '')      as varchar)       as source_customer_id,
    cast(coalesce(source_supplier_code, '')    as varchar)       as source_supplier_code,
    cast(coalesce(source_user_id, '')          as varchar)       as source_user_id,
    cast(coalesce(owner_id, '')                as varchar)       as owner_id,
    coalesce(total_orders, 0)                                    as total_orders,
    coalesce(loyalty_balance, 0)                                 as loyalty_balance,
    cast(coalesce(lifetime_value, 0)           as decimal(18,2)) as lifetime_value,
    cast(last_order_at                         as timestamp)     as last_order_at,
    cast(created_at                            as timestamp)     as created_at,
    cast(updated_at                            as timestamp)     as updated_at,
    cast(deleted_at                            as timestamp)     as deleted_at,
    cast(_airbyte_extracted_at                 as timestamp)     as _etl_loaded_at
from {{ source('crm', 'accounts') }}
where id is not null
