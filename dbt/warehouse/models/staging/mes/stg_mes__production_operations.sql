{{ config(tags=['staging', 'mes']) }}

with source as (

    select * from {{ source('mes', 'production_operations') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(production_order_id,   _airbyte_extracted_at) as production_order_id,
        argMax(sequence_number,       _airbyte_extracted_at) as sequence_number,
        argMax(operation_name,        _airbyte_extracted_at) as operation_name,
        argMax(work_center_id,        _airbyte_extracted_at) as work_center_id,
        argMax(status,                _airbyte_extracted_at) as status,
        argMax(setup_time_minutes,    _airbyte_extracted_at) as setup_time_minutes,
        argMax(run_time_minutes,      _airbyte_extracted_at) as run_time_minutes,
        argMax(actual_time_minutes,   _airbyte_extracted_at) as actual_time_minutes,
        argMax(started_at,            _airbyte_extracted_at) as started_at,
        argMax(completed_at,          _airbyte_extracted_at) as completed_at,
        argMax(operator_id,           _airbyte_extracted_at) as operator_id,
        argMax(created_at,            _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                           as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                      as varchar)       as id_production_operation,
    cast(coalesce(production_order_id, '')       as varchar)       as production_order_id,
    coalesce(sequence_number, 0)                                   as sequence_number,
    cast(coalesce(operation_name, '')            as varchar)       as operation_name,
    cast(coalesce(work_center_id, '')            as varchar)       as work_center_id,
    cast(coalesce(status, '')                    as varchar)       as status,
    cast(coalesce(setup_time_minutes, 0)         as decimal(18,2)) as setup_time_minutes,
    cast(coalesce(run_time_minutes, 0)           as decimal(18,2)) as run_time_minutes,
    cast(coalesce(actual_time_minutes, 0)        as decimal(18,2)) as actual_time_minutes,
    toDateTimeOrNull(toString(started_at))                         as started_at,
    toDateTimeOrNull(toString(completed_at))                       as completed_at,
    cast(coalesce(operator_id, '')               as varchar)       as operator_id,
    cast(created_at                              as timestamp)     as created_at,
    cast(latest_extracted_at                     as timestamp)     as _etl_loaded_at
from deduped
