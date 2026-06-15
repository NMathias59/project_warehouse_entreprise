{{ config(tags=['staging', 'procurement']) }}

with base as (

    select * from {{ ref('base_procurement__contract_lines') }}

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
    cast(latest_extracted_at                as timestamp)     as _etl_loaded_at
from base
