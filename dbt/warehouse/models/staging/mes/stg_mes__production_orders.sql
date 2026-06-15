{{ config(tags=['staging', 'mes']) }}

with source as (

    select * from {{ source('mes', 'production_orders') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(order_number,  _airbyte_extracted_at) as reference,
        argMax(status,        _airbyte_extracted_at) as status,
        argMax(product_sku,   _airbyte_extracted_at) as product_id,
        argMax(qty_planned,   _airbyte_extracted_at) as quantity_planned,
        argMax(qty_completed, _airbyte_extracted_at) as quantity_produced,
        argMax(qty_scrapped,  _airbyte_extracted_at) as quantity_scrapped,
        argMax(planned_start, _airbyte_extracted_at) as planned_start_at,
        argMax(planned_end,   _airbyte_extracted_at) as planned_end_at,
        argMax(actual_start,  _airbyte_extracted_at) as actual_start_at,
        argMax(actual_end,    _airbyte_extracted_at) as actual_end_at,
        argMax(created_at,    _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                   as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                   as varchar)       as id_production_order,
    cast(coalesce(reference, '')              as varchar)       as reference,
    cast(coalesce(status, '')                 as varchar)       as status,
    cast(coalesce(product_id, '')             as varchar)       as product_id,
    cast(''                                   as varchar)       as bom_id,
    cast(''                                   as varchar)       as work_center_id,
    cast(''                                   as varchar)       as shift_id,
    cast(coalesce(quantity_planned, 0)        as decimal(18,2)) as quantity_planned,
    cast(coalesce(quantity_produced, 0)       as decimal(18,2)) as quantity_produced,
    cast(coalesce(quantity_scrapped, 0)       as decimal(18,2)) as quantity_scrapped,
    toDateTimeOrNull(toString(planned_start_at))                as planned_start_at,
    toDateTimeOrNull(toString(planned_end_at))                  as planned_end_at,
    toDateTimeOrNull(toString(actual_start_at))                 as actual_start_at,
    toDateTimeOrNull(toString(actual_end_at))                   as actual_end_at,
    cast(''                                   as varchar)       as created_by,
    cast(created_at                           as timestamp)     as created_at,
    cast(null as Nullable(DateTime64(3)))                       as updated_at,
    cast(latest_extracted_at                  as timestamp)     as _etl_loaded_at
from deduped
