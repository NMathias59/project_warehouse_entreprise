{{ config(tags=['staging', 'finance']) }}

with base as (

    select * from {{ ref('base_finance__bank_transactions') }}

)

select
    cast(id                                   as varchar)        as id_bank_transaction,
    cast(coalesce(bank_account_id,   '')      as varchar)        as bank_account_id,
    cast(transaction_date                     as date)           as transaction_date,
    cast(value_date                           as Nullable(Date)) as value_date,
    cast(coalesce(direction,         '')      as varchar)        as transaction_type,
    cast(coalesce(description,       '')      as varchar)        as description,
    cast(coalesce(amount_eur,        0)       as decimal(18,2))  as amount,
    cast(''                                   as varchar)        as currency,
    cast(coalesce(reference,         '')      as varchar)        as reference,
    cast(coalesce(reconciled,        false)   as boolean)        as is_reconciled,
    cast(coalesce(journal_entry_id,  '')      as varchar)        as journal_line_id,
    cast(created_at                           as timestamp)      as created_at,
    cast(latest_extracted_at                as timestamp)      as _etl_loaded_at
from base
