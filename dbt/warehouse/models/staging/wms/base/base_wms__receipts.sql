{{ config(materialized='view', tags=['staging', 'wms']) }}

select
    id,
    argMax(receipt_number, _airbyte_extracted_at) as receipt_number,
    argMax(status,         _airbyte_extracted_at) as status,
    argMax(supplier_ref,   _airbyte_extracted_at) as supplier_ref,
    argMax(erp_po_ref,     _airbyte_extracted_at) as erp_po_ref,
    argMax(expected_at,    _airbyte_extracted_at) as expected_at,
    argMax(received_at,    _airbyte_extracted_at) as received_at,
    argMax(notes,          _airbyte_extracted_at) as notes,
    argMax(created_at,     _airbyte_extracted_at) as created_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('wms', 'receipts') }}
where id is not null
group by id
