{{ config(tags=['staging', 'procurement']) }}

with source as (

    select * from {{ source('procurement', 'rfq_lines') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(rfq_id,           _airbyte_extracted_at) as rfq_id,
        argMax(product_id,       _airbyte_extracted_at) as product_id,
        argMax(description,      _airbyte_extracted_at) as description,
        argMax(quantity,         _airbyte_extracted_at) as quantity,
        argMax(unit_of_measure,  _airbyte_extracted_at) as unit_of_measure,
        argMax(created_at,       _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                      as latest_extracted_at
    from source
    group by id

)

select
    cast(id                               as varchar)       as id_rfq_line,
    cast(coalesce(rfq_id, '')             as varchar)       as rfq_id,
    cast(coalesce(product_id, '')         as varchar)       as product_id,
    cast(coalesce(description, '')        as varchar)       as description,
    cast(coalesce(quantity, 0)            as decimal(18,2)) as quantity,
    cast(coalesce(unit_of_measure, '')    as varchar)       as unit_of_measure,
    cast(created_at                       as timestamp)     as created_at,
    cast(latest_extracted_at              as timestamp)     as _etl_loaded_at
from deduped
