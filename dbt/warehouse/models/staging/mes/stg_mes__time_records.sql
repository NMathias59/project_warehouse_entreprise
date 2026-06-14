{{ config(tags=['staging', 'mes']) }}

with source as (

    select * from {{ source('mes', 'time_records') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(production_order_id, _airbyte_extracted_at) as production_order_id,
        argMax(operation_id,        _airbyte_extracted_at) as operation_id,
        argMax(operator_id,         _airbyte_extracted_at) as operator_id,
        argMax(work_center_id,      _airbyte_extracted_at) as work_center_id,
        argMax(record_type,         _airbyte_extracted_at) as record_type,
        argMax(duration_minutes,    _airbyte_extracted_at) as duration_minutes,
        argMax(recorded_at,         _airbyte_extracted_at) as recorded_at,
        argMax(created_at,          _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                         as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                     as varchar)       as id_time_record,
    cast(coalesce(production_order_id, '')      as varchar)       as production_order_id,
    cast(coalesce(operation_id, '')             as varchar)       as operation_id,
    cast(coalesce(operator_id, '')              as varchar)       as operator_id,
    cast(coalesce(work_center_id, '')           as varchar)       as work_center_id,
    cast(coalesce(record_type, '')              as varchar)       as record_type,
    cast(coalesce(duration_minutes, 0)          as decimal(18,2)) as duration_minutes,
    cast(recorded_at                            as timestamp)     as recorded_at,
    cast(created_at                             as timestamp)     as created_at,
    cast(latest_extracted_at                    as timestamp)     as _etl_loaded_at
from deduped
