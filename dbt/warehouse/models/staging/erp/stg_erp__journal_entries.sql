{{ config(tags=['staging', 'erp']) }}

with source as (
    select * from {{ source('erp', 'journal_entries') }}
)

select
    cast(id as varchar)                as id_journal_entry,
    cast(label as varchar)             as label,
    cast(reference as varchar)         as reference,
    cast(entry_date as date)           as entry_date,
    cast(created_at as timestamp)      as created_at,
    cast(fiscal_year_id as varchar)    as fiscal_year_id
from source
where id is not null
