{{ config(tags=['staging', 'procurement']) }}

with source as (

    select * from {{ source('procurement', 'receipt_lines') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(receipt_id,               _airbyte_extracted_at) as receipt_id,
        argMax(purchase_order_line_id,   _airbyte_extracted_at) as purchase_order_line_id,
        argMax(product_id,               _airbyte_extracted_at) as product_id,
        argMax(quantity_received,        _airbyte_extracted_at) as quantity_received,
        argMax(unit_cost,                _airbyte_extracted_at) as unit_cost,
        argMax(lot_number,               _airbyte_extracted_at) as lot_number,
        argMax(created_at,               _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                              as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                      as varchar)       as id_receipt_line,
    cast(coalesce(receipt_id, '')                as varchar)       as receipt_id,
    cast(coalesce(purchase_order_line_id, '')    as varchar)       as purchase_order_line_id,
    cast(coalesce(product_id, '')                as varchar)       as product_id,
    cast(coalesce(quantity_received, 0)          as decimal(18,2)) as quantity_received,
    cast(coalesce(unit_cost, 0)                  as decimal(18,2)) as unit_cost,
    cast(coalesce(lot_number, '')                as varchar)       as lot_number,
    cast(created_at                              as timestamp)     as created_at,
    cast(latest_extracted_at                     as timestamp)     as _etl_loaded_at
from deduped
