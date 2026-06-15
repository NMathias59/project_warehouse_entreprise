{{ config(materialized='view', tags=['staging', 'crm']) }}

select
    id,
    argMax(title,             _airbyte_extracted_at) as title,
    argMax(stage,             _airbyte_extracted_at) as stage,
    argMax(status,            _airbyte_extracted_at) as status,
    argMax(origin,            _airbyte_extracted_at) as origin,
    argMax(notes,             _airbyte_extracted_at) as notes,
    argMax(account_id,        _airbyte_extracted_at) as account_id,
    argMax(owner_id,          _airbyte_extracted_at) as owner_id,
    argMax(source_order_id,   _airbyte_extracted_at) as source_order_id,
    argMax(probability,       _airbyte_extracted_at) as probability,
    argMax(amount_estimated,  _airbyte_extracted_at) as amount_estimated,
    argMax(expected_close_at, _airbyte_extracted_at) as expected_close_at,
    argMax(created_at,        _airbyte_extracted_at) as created_at,
    argMax(updated_at,        _airbyte_extracted_at) as updated_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('crm', 'opportunities') }}
where id is not null
group by id
