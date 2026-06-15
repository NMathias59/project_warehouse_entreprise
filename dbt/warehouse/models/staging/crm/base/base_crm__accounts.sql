{{ config(materialized='view', tags=['staging', 'crm']) }}

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
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('crm', 'accounts') }}
where id is not null
group by id
