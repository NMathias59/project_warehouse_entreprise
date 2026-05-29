{{ config(tags=['staging', 'erp']) }}

with source as (
    select * from {{ source('erp', 'budget_lines') }}
)

select
    cast(id as varchar)                as id_budget_line,
    cast(budget_id as varchar)         as budget_id,
    cast(notes as varchar)             as notes,
    cast(amount as decimal(38,9))      as amount,
    cast(created_at as timestamp)      as created_at,
    cast(account_number as varchar)    as account_number
from source
where id is not null
