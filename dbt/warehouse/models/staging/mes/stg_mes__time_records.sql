{{ config(tags=['staging', 'mes']) }}

with source as (

    select * from {{ source('mes', 'time_records') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(job_card_id,  _airbyte_extracted_at) as operation_id,
        argMax(operator_id,  _airbyte_extracted_at) as operator_id,
        argMax(event_type,   _airbyte_extracted_at) as record_type,
        argMax(occurred_at,  _airbyte_extracted_at) as recorded_at,
        max(_airbyte_extracted_at)                  as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                     as varchar)       as id_time_record,
    cast(''                                     as varchar)       as production_order_id,
    cast(coalesce(operation_id, '')             as varchar)       as operation_id,
    cast(coalesce(operator_id, '')              as varchar)       as operator_id,
    cast(''                                     as varchar)       as work_center_id,
    cast(coalesce(record_type, '')              as varchar)       as record_type,
    cast(0                                      as decimal(18,2)) as duration_minutes,
    cast(recorded_at                            as timestamp)     as recorded_at,
    cast(null as Nullable(DateTime64(3)))                         as created_at,
    cast(latest_extracted_at                    as timestamp)     as _etl_loaded_at
from deduped
