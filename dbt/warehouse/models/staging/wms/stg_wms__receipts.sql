{{ config(tags=['staging', 'wms']) }}

with base as (

    select * from {{ ref('base_wms__receipts') }}

)

select
    cast(id                                      as varchar)   as id_receipt,
    cast(coalesce(receipt_number, '')            as varchar)   as reference,
    cast(coalesce(status,         '')            as varchar)   as status,
    cast(coalesce(supplier_ref,   '')            as varchar)   as supplier_id,
    cast(''                                      as varchar)   as warehouse_id,
    cast(coalesce(erp_po_ref,     '')            as varchar)   as purchase_order_id,
    toDateTimeOrNull(toString(expected_at))                    as expected_at,
    toDateTimeOrNull(toString(received_at))                    as received_at,
    cast(coalesce(notes,          '')            as varchar)   as notes,
    cast(created_at                              as timestamp) as created_at,
    cast(null as Nullable(DateTime64(3)))                      as updated_at,
    cast(latest_extracted_at                as timestamp) as _etl_loaded_at
from base
