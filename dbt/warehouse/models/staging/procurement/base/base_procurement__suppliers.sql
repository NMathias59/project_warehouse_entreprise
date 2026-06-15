{{ config(materialized='view', tags=['staging', 'procurement']) }}

select
    id,
    argMax(supplier_ref,        _airbyte_extracted_at) as code,
    argMax(name,                _airbyte_extracted_at) as name,
    argMax(tier,                _airbyte_extracted_at) as supplier_type,
    argMax(is_active,           _airbyte_extracted_at) as is_active,
    argMax(country,             _airbyte_extracted_at) as country_code,
    argMax(payment_terms_days,  _airbyte_extracted_at) as payment_terms_days,
    argMax(currency,            _airbyte_extracted_at) as currency,
    argMax(created_at,          _airbyte_extracted_at) as created_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('procurement', 'suppliers') }}
where id is not null
group by id
