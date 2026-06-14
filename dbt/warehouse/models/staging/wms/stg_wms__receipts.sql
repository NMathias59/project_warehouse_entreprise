{{ config(tags=['staging', 'wms']) }}

with source as (

    select * from {{ source('wms', 'receipts') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(reference,          _airbyte_extracted_at) as reference,
        argMax(status,             _airbyte_extracted_at) as status,
        argMax(supplier_id,        _airbyte_extracted_at) as supplier_id,
        argMax(warehouse_id,       _airbyte_extracted_at) as warehouse_id,
        argMax(purchase_order_id,  _airbyte_extracted_at) as purchase_order_id,
        argMax(expected_at,        _airbyte_extracted_at) as expected_at,
        argMax(received_at,        _airbyte_extracted_at) as received_at,
        argMax(notes,              _airbyte_extracted_at) as notes,
        argMax(created_at,         _airbyte_extracted_at) as created_at,
        argMax(updated_at,         _airbyte_extracted_at) as updated_at,
        max(_airbyte_extracted_at)                        as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                  as varchar)   as id_receipt,
    cast(coalesce(reference, '')             as varchar)   as reference,
    cast(coalesce(status, '')                as varchar)   as status,
    cast(coalesce(supplier_id, '')           as varchar)   as supplier_id,
    cast(coalesce(warehouse_id, '')          as varchar)   as warehouse_id,
    cast(coalesce(purchase_order_id, '')     as varchar)   as purchase_order_id,
    toDateTimeOrNull(toString(expected_at))               as expected_at,
    toDateTimeOrNull(toString(received_at))               as received_at,
    cast(coalesce(notes, '')                 as varchar)   as notes,
    cast(created_at                          as timestamp) as created_at,
    toDateTimeOrNull(toString(updated_at))                as updated_at,
    cast(latest_extracted_at                 as timestamp) as _etl_loaded_at
from deduped
