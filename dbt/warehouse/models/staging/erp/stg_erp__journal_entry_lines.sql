{{ config(tags=['staging', 'erp']) }}

with source as (
    select * from {{ source('erp', 'journal_entry_lines') }}
)

select
    cast(id as varchar)                as id_journal_entry_line,
    cast(journal_entry_id as varchar)  as journal_entry_id,
    cast(debit as decimal(38,9))       as debit,
    cast(credit as decimal(38,9))      as credit,
    cast(account_label as varchar)     as account_label,
    cast(account_number as varchar)    as account_number,
    cast(cost_center_id as varchar)    as cost_center_id,
    cast(_ab_cdc_updated_at as varchar) as updated_at
from source
where id is not null
