{{ config(tags=['staging', 'crm']) }}

-- Déduplication ClickHouse-native via argMax :
-- Airbyte CDC insère une ligne par événement (INSERT/UPDATE) pour le même id.
-- argMax(col, _airbyte_extracted_at) garde la valeur la plus récente par colonne.
-- Plus performant que ROW_NUMBER() : single-pass, pas de sort.

with source as (

    select * from {{ source('crm', 'accounts') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(name,                  _airbyte_extracted_at) as name,
        argMax(account_type,          _airbyte_extracted_at) as account_type,
        argMax(status,                _airbyte_extracted_at) as status,
        argMax(segment,               _airbyte_extracted_at) as segment,
        argMax(email,                 _airbyte_extracted_at) as email,
        argMax(phone,                 _airbyte_extracted_at) as phone,
        argMax(website,               _airbyte_extracted_at) as website,
        argMax(city,                  _airbyte_extracted_at) as city,
        argMax(country_code,          _airbyte_extracted_at) as country_code,
        argMax(external_ref,          _airbyte_extracted_at) as external_ref,
        argMax(source_customer_id,    _airbyte_extracted_at) as source_customer_id,
        argMax(source_supplier_code,  _airbyte_extracted_at) as source_supplier_code,
        argMax(source_user_id,        _airbyte_extracted_at) as source_user_id,
        argMax(owner_id,              _airbyte_extracted_at) as owner_id,
        argMax(total_orders,          _airbyte_extracted_at) as total_orders,
        argMax(loyalty_balance,       _airbyte_extracted_at) as loyalty_balance,
        argMax(lifetime_value,        _airbyte_extracted_at) as lifetime_value,
        argMax(last_order_at,         _airbyte_extracted_at) as last_order_at,
        argMax(created_at,            _airbyte_extracted_at) as created_at,
        argMax(updated_at,            _airbyte_extracted_at) as updated_at,
        argMax(deleted_at,            _airbyte_extracted_at) as deleted_at,
        max(_airbyte_extracted_at)                           as latest_extracted_at
    from source
    group by id

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
    cast(latest_extracted_at                   as timestamp)     as _etl_loaded_at
from deduped
