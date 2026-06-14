{{ config(tags=['staging', 'procurement']) }}

with source as (

    select * from {{ source('procurement', 'receipts') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(reference,          _airbyte_extracted_at) as reference,
        argMax(purchase_order_id,  _airbyte_extracted_at) as purchase_order_id,
        argMax(warehouse_id,       _airbyte_extracted_at) as warehouse_id,
        argMax(status,             _airbyte_extracted_at) as status,
        argMax(received_by,        _airbyte_extracted_at) as received_by,
        argMax(received_at,        _airbyte_extracted_at) as received_at,
        argMax(created_at,         _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                        as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                  as varchar)   as id_receipt,
    cast(coalesce(reference, '')             as varchar)   as reference,
    cast(coalesce(purchase_order_id, '')     as varchar)   as purchase_order_id,
    cast(coalesce(warehouse_id, '')          as varchar)   as warehouse_id,
    cast(coalesce(status, '')                as varchar)   as status,
    cast(coalesce(received_by, '')           as varchar)   as received_by,
    cast(received_at                         as timestamp) as received_at,
    cast(created_at                          as timestamp) as created_at,
    cast(latest_extracted_at                 as timestamp) as _etl_loaded_at
from deduped
