{{ config(tags=['staging', 'procurement']) }}

with source as (

    select * from {{ source('procurement', 'contract_lines') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(contract_id,     _airbyte_extracted_at) as contract_id,
        argMax(component_sku,   _airbyte_extracted_at) as product_id,
        argMax(component_name,  _airbyte_extracted_at) as description,
        argMax(agreed_price_eur, _airbyte_extracted_at) as unit_price,
        argMax(min_qty,         _airbyte_extracted_at) as quantity_min,
        argMax(max_qty,         _airbyte_extracted_at) as quantity_max,
        max(_airbyte_extracted_at)                     as latest_extracted_at
    from source
    group by id

)

select
    cast(id                               as varchar)       as id_contract_line,
    cast(coalesce(contract_id, '')        as varchar)       as contract_id,
    cast(coalesce(product_id, '')         as varchar)       as product_id,
    cast(coalesce(description, '')        as varchar)       as description,
    cast(coalesce(unit_price, 0)          as decimal(18,2)) as unit_price,
    cast(coalesce(quantity_min, 0)        as decimal(18,2)) as quantity_min,
    cast(coalesce(quantity_max, 0)        as decimal(18,2)) as quantity_max,
    cast(''                               as varchar)       as unit_of_measure,
    cast(null as Nullable(DateTime64(3)))                   as created_at,
    cast(latest_extracted_at              as timestamp)     as _etl_loaded_at
from deduped
