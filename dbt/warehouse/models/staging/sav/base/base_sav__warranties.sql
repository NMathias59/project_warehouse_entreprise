{{ config(materialized='view', tags=['staging', 'sav']) }}

select
    id,
    argMax(customer_ref,  _airbyte_extracted_at) as customer_id,
    argMax(product_sku,   _airbyte_extracted_at) as product_id,
    argMax(serial_number, _airbyte_extracted_at) as serial_number,
    argMax(warranty_type, _airbyte_extracted_at) as warranty_type,
    argMax(status,        _airbyte_extracted_at) as status,
    argMax(created_at,    _airbyte_extracted_at) as created_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('sav', 'warranties') }}
where id is not null
group by id
