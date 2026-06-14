{{ config(tags=['staging', 'procurement']) }}

with source as (

    select * from {{ source('procurement', 'purchase_order_lines') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(purchase_order_id,     _airbyte_extracted_at) as purchase_order_id,
        argMax(product_id,            _airbyte_extracted_at) as product_id,
        argMax(description,           _airbyte_extracted_at) as description,
        argMax(quantity_ordered,      _airbyte_extracted_at) as quantity_ordered,
        argMax(quantity_received,     _airbyte_extracted_at) as quantity_received,
        argMax(unit_price,            _airbyte_extracted_at) as unit_price,
        argMax(unit_of_measure,       _airbyte_extracted_at) as unit_of_measure,
        argMax(expected_delivery_at,  _airbyte_extracted_at) as expected_delivery_at,
        argMax(created_at,            _airbyte_extracted_at) as created_at,
        argMax(updated_at,            _airbyte_extracted_at) as updated_at,
        max(_airbyte_extracted_at)                           as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                       as varchar)       as id_purchase_order_line,
    cast(coalesce(purchase_order_id, '')          as varchar)       as purchase_order_id,
    cast(coalesce(product_id, '')                 as varchar)       as product_id,
    cast(coalesce(description, '')                as varchar)       as description,
    cast(coalesce(quantity_ordered, 0)            as decimal(18,2)) as quantity_ordered,
    cast(coalesce(quantity_received, 0)           as decimal(18,2)) as quantity_received,
    cast(coalesce(unit_price, 0)                  as decimal(18,2)) as unit_price,
    cast(coalesce(unit_of_measure, '')            as varchar)       as unit_of_measure,
    toDateTimeOrNull(toString(expected_delivery_at))                as expected_delivery_at,
    cast(created_at                               as timestamp)     as created_at,
    toDateTimeOrNull(toString(updated_at))                          as updated_at,
    cast(latest_extracted_at                      as timestamp)     as _etl_loaded_at
from deduped
