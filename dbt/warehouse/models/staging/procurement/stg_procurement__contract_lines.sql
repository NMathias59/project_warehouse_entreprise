{{ config(tags=['staging', 'procurement']) }}

with source as (

    select * from {{ source('procurement', 'contract_lines') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(contract_id,      _airbyte_extracted_at) as contract_id,
        argMax(product_id,       _airbyte_extracted_at) as product_id,
        argMax(description,      _airbyte_extracted_at) as description,
        argMax(unit_price,       _airbyte_extracted_at) as unit_price,
        argMax(quantity_min,     _airbyte_extracted_at) as quantity_min,
        argMax(quantity_max,     _airbyte_extracted_at) as quantity_max,
        argMax(unit_of_measure,  _airbyte_extracted_at) as unit_of_measure,
        argMax(created_at,       _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                      as latest_extracted_at
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
    cast(coalesce(unit_of_measure, '')    as varchar)       as unit_of_measure,
    cast(created_at                       as timestamp)     as created_at,
    cast(latest_extracted_at              as timestamp)     as _etl_loaded_at
from deduped
