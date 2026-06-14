{{ config(tags=['staging', 'mes']) }}

with source as (

    select * from {{ source('mes', 'production_orders') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(reference,          _airbyte_extracted_at) as reference,
        argMax(status,             _airbyte_extracted_at) as status,
        argMax(product_id,         _airbyte_extracted_at) as product_id,
        argMax(bom_id,             _airbyte_extracted_at) as bom_id,
        argMax(work_center_id,     _airbyte_extracted_at) as work_center_id,
        argMax(shift_id,           _airbyte_extracted_at) as shift_id,
        argMax(quantity_planned,   _airbyte_extracted_at) as quantity_planned,
        argMax(quantity_produced,  _airbyte_extracted_at) as quantity_produced,
        argMax(quantity_scrapped,  _airbyte_extracted_at) as quantity_scrapped,
        argMax(planned_start_at,   _airbyte_extracted_at) as planned_start_at,
        argMax(planned_end_at,     _airbyte_extracted_at) as planned_end_at,
        argMax(actual_start_at,    _airbyte_extracted_at) as actual_start_at,
        argMax(actual_end_at,      _airbyte_extracted_at) as actual_end_at,
        argMax(created_by,         _airbyte_extracted_at) as created_by,
        argMax(created_at,         _airbyte_extracted_at) as created_at,
        argMax(updated_at,         _airbyte_extracted_at) as updated_at,
        max(_airbyte_extracted_at)                        as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                   as varchar)       as id_production_order,
    cast(coalesce(reference, '')              as varchar)       as reference,
    cast(coalesce(status, '')                 as varchar)       as status,
    cast(coalesce(product_id, '')             as varchar)       as product_id,
    cast(coalesce(bom_id, '')                 as varchar)       as bom_id,
    cast(coalesce(work_center_id, '')         as varchar)       as work_center_id,
    cast(coalesce(shift_id, '')               as varchar)       as shift_id,
    cast(coalesce(quantity_planned, 0)        as decimal(18,2)) as quantity_planned,
    cast(coalesce(quantity_produced, 0)       as decimal(18,2)) as quantity_produced,
    cast(coalesce(quantity_scrapped, 0)       as decimal(18,2)) as quantity_scrapped,
    toDateTimeOrNull(toString(planned_start_at))                as planned_start_at,
    toDateTimeOrNull(toString(planned_end_at))                  as planned_end_at,
    toDateTimeOrNull(toString(actual_start_at))                 as actual_start_at,
    toDateTimeOrNull(toString(actual_end_at))                   as actual_end_at,
    cast(coalesce(created_by, '')             as varchar)       as created_by,
    cast(created_at                           as timestamp)     as created_at,
    toDateTimeOrNull(toString(updated_at))                      as updated_at,
    cast(latest_extracted_at                  as timestamp)     as _etl_loaded_at
from deduped
