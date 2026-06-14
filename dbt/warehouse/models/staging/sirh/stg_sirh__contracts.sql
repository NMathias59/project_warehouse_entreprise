{{ config(tags=['staging', 'sirh']) }}

with source as (

    select * from {{ source('sirh', 'contracts') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(employee_id,              _airbyte_extracted_at) as employee_id,
        argMax(contract_type,            _airbyte_extracted_at) as contract_type,
        argMax(status,                   _airbyte_extracted_at) as status,
        argMax(start_date,               _airbyte_extracted_at) as start_date,
        argMax(end_date,                 _airbyte_extracted_at) as end_date,
        argMax(gross_salary,             _airbyte_extracted_at) as gross_salary,
        argMax(working_hours_per_week,   _airbyte_extracted_at) as working_hours_per_week,
        argMax(created_at,               _airbyte_extracted_at) as created_at,
        argMax(updated_at,               _airbyte_extracted_at) as updated_at,
        max(_airbyte_extracted_at)                              as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                      as varchar)       as id_contract,
    cast(coalesce(employee_id, '')               as varchar)       as employee_id,
    cast(coalesce(contract_type, '')             as varchar)       as contract_type,
    cast(coalesce(status, '')                    as varchar)       as status,
    cast(start_date                              as date)          as start_date,
    cast(end_date                                as date)          as end_date,
    cast(coalesce(gross_salary, 0)               as decimal(18,2)) as gross_salary,
    cast(coalesce(working_hours_per_week, 0)     as decimal(18,2)) as working_hours_per_week,
    cast(created_at                              as timestamp)     as created_at,
    toDateTimeOrNull(toString(updated_at))                         as updated_at,
    cast(latest_extracted_at                     as timestamp)     as _etl_loaded_at
from deduped
