{{ config(materialized='view', tags=['staging', 'crm']) }}

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
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('crm', 'contacts') }}
where id is not null
group by id
