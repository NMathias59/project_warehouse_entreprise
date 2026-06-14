{{ config(materialized='ephemeral', tags=['intermediate', 'finance']) }}

with bank_transactions as (
    select * from {{ ref('stg_finance__bank_transactions') }}
)

select
    bank_account_id,
    toYear(transaction_date)                                        as transaction_year,
    toMonth(transaction_date)                                       as transaction_month,
    count(id_bank_transaction)                                      as nb_transactions,
    sumIf(amount, transaction_type = 'debit')                       as total_debit,
    sumIf(amount, transaction_type = 'credit')                      as total_credit,
    sumIf(amount, transaction_type = 'credit')
        - sumIf(amount, transaction_type = 'debit')                 as net_flow,
    countIf(is_reconciled)                                          as nb_reconciled,
    countIf(not is_reconciled)                                      as nb_unreconciled
from bank_transactions
group by
    bank_account_id,
    toYear(transaction_date),
    toMonth(transaction_date)
