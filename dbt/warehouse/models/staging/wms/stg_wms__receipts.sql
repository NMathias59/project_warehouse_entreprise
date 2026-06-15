{{ config(tags=['staging', 'wms']) }}

select
    cast(id                                                                   as varchar)   as id_receipt,
    cast(coalesce(argMax(receipt_number, _airbyte_extracted_at), '')          as varchar)   as reference,
    cast(coalesce(argMax(status,         _airbyte_extracted_at), '')          as varchar)   as status,
    cast(coalesce(argMax(supplier_ref,   _airbyte_extracted_at), '')          as varchar)   as supplier_id,
    cast(''                                                                   as varchar)   as warehouse_id,
    cast(coalesce(argMax(erp_po_ref,     _airbyte_extracted_at), '')          as varchar)   as purchase_order_id,
    toDateTimeOrNull(toString(argMax(expected_at,  _airbyte_extracted_at)))                as expected_at,
    toDateTimeOrNull(toString(argMax(received_at,  _airbyte_extracted_at)))                as received_at,
    cast(coalesce(argMax(notes,          _airbyte_extracted_at), '')          as varchar)   as notes,
    cast(argMax(created_at,              _airbyte_extracted_at)               as timestamp) as created_at,
    cast(null                                                                 as Nullable(DateTime64(3))) as updated_at,
    cast(max(_airbyte_extracted_at)                                           as timestamp) as _etl_loaded_at
from {{ source('wms', 'receipts') }}
where id is not null
group by id
