{{ config(tags=['staging', 'sav']) }}

with source as (

    select * from {{ source('sav', 'spare_parts_used') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(rma_id,             _airbyte_extracted_at) as intervention_id,
        argMax(product_sku,        _airbyte_extracted_at) as part_reference,
        argMax(defect_description, _airbyte_extracted_at) as part_name,
        argMax(qty,                _airbyte_extracted_at) as quantity,
        max(_airbyte_extracted_at)                        as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                     as varchar)       as id_spare_part_used,
    cast(coalesce(intervention_id, '')          as varchar)       as intervention_id,
    cast(coalesce(part_reference, '')           as varchar)       as part_reference,
    cast(coalesce(part_name, '')                as varchar)       as part_name,
    cast(coalesce(quantity, 0)                  as decimal(18,2)) as quantity,
    cast(0                                      as decimal(18,2)) as unit_cost,
    cast(false                                  as boolean)       as is_under_warranty,
    cast(null as Nullable(DateTime64(3)))                         as created_at,
    cast(latest_extracted_at                    as timestamp)     as _etl_loaded_at
from deduped
