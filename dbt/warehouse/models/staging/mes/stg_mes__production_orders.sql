{{ config(tags=['staging', 'mes']) }}

with base as (

    select * from {{ ref('base_mes__production_orders') }}

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
    cast(latest_extracted_at                as timestamp)     as _etl_loaded_at
from base
