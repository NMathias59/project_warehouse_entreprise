{{ config(tags=['staging', 'mes']) }}

with base as (

    select * from {{ ref('base_mes__production_operations') }}

)

select
    cast(id                                      as varchar)       as id_production_operation,
    cast(''                                      as varchar)       as production_order_id,
    coalesce(sequence_number, 0)                                   as sequence_number,
    cast(coalesce(operation_name, '')            as varchar)       as operation_name,
    cast(coalesce(work_center_id, '')            as varchar)       as work_center_id,
    cast(''                                      as varchar)       as status,
    cast(0                                       as decimal(18,2)) as setup_time_minutes,
    cast(coalesce(run_time_minutes, 0)           as decimal(18,2)) as run_time_minutes,
    cast(0                                       as decimal(18,2)) as actual_time_minutes,
    cast(null as Nullable(DateTime64(3)))                          as started_at,
    cast(null as Nullable(DateTime64(3)))                          as completed_at,
    cast(''                                      as varchar)       as operator_id,
    cast(null as Nullable(DateTime64(3)))                          as created_at,
    cast(latest_extracted_at                as timestamp)     as _etl_loaded_at
from base
