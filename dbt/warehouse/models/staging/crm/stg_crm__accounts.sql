{{ config(tags=['staging', 'crm']) }}

-- Déduplication ClickHouse-native via argMax :
-- Airbyte CDC insère une ligne par événement (INSERT/UPDATE) pour le même id.
-- argMax(col, _airbyte_extracted_at) garde la valeur la plus récente par colonne.
-- Plus performant que ROW_NUMBER() : single-pass, pas de sort.

with base as (

    select * from {{ ref('base_crm__accounts') }}

)

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
    toDateTimeOrNull(toString(last_order_at))                    as last_order_at,
    cast(created_at                            as timestamp)     as created_at,
    toDateTimeOrNull(toString(updated_at))                       as updated_at,
    toDateTimeOrNull(toString(deleted_at))                       as deleted_at,
    cast(latest_extracted_at                as timestamp)     as _etl_loaded_at
from base
