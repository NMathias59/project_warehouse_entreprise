{{ config(tags=['staging', 'finance']) }}

with source as (

    select * from {{ source('finance', 'budget_lines') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(budget_id,       _airbyte_extracted_at) as budget_id,
        argMax(account_id,      _airbyte_extracted_at) as account_id,
        argMax(cost_center_id,  _airbyte_extracted_at) as cost_center_id,
        argMax(period_number,   _airbyte_extracted_at) as period_number,
        argMax(amount,          _airbyte_extracted_at) as amount,
        argMax(notes,           _airbyte_extracted_at) as notes,
        argMax(created_at,      _airbyte_extracted_at) as created_at,
        argMax(updated_at,      _airbyte_extracted_at) as updated_at,
        max(_airbyte_extracted_at)                     as latest_extracted_at
    from source
    group by id

)

select
    cast(id                               as varchar)       as id_budget_line,
    cast(coalesce(budget_id, '')          as varchar)       as budget_id,
    cast(coalesce(account_id, '')         as varchar)       as account_id,
    cast(coalesce(cost_center_id, '')     as varchar)       as cost_center_id,
    coalesce(period_number, 0)                              as period_number,
    cast(coalesce(amount, 0)              as decimal(18,2)) as amount,
    cast(coalesce(notes, '')              as varchar)       as notes,
    cast(created_at                       as timestamp)     as created_at,
    toDateTimeOrNull(toString(updated_at))                  as updated_at,
    cast(latest_extracted_at              as timestamp)     as _etl_loaded_at
from deduped
