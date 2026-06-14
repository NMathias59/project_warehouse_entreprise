{{ config(tags=['staging', 'sirh']) }}

with source as (

    select * from {{ source('sirh', 'payslip_lines') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(payslip_id,  _airbyte_extracted_at) as payslip_id,
        argMax(line_type,   _airbyte_extracted_at) as line_type,
        argMax(label,       _airbyte_extracted_at) as label,
        argMax(quantity,    _airbyte_extracted_at) as quantity,
        argMax(unit_rate,   _airbyte_extracted_at) as unit_rate,
        argMax(amount,      _airbyte_extracted_at) as amount,
        argMax(created_at,  _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                 as latest_extracted_at
    from source
    group by id

)

select
    cast(id                              as varchar)       as id_payslip_line,
    cast(coalesce(payslip_id, '')        as varchar)       as payslip_id,
    cast(coalesce(line_type, '')         as varchar)       as line_type,
    cast(coalesce(label, '')             as varchar)       as label,
    cast(coalesce(quantity, 0)           as decimal(18,2)) as quantity,
    cast(coalesce(unit_rate, 0)          as decimal(18,2)) as unit_rate,
    cast(coalesce(amount, 0)             as decimal(18,2)) as amount,
    cast(created_at                      as timestamp)     as created_at,
    cast(latest_extracted_at             as timestamp)     as _etl_loaded_at
from deduped
