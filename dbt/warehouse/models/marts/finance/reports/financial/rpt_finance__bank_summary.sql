{{ config(materialized='table', engine='MergeTree()', order_by='(bank_account_id, transaction_year, transaction_month)', tags=['reports','finance','financial']) }}
with txns as (
    select
        bank_account_id, transaction_type, amount, is_reconciled, transaction_date
    from {{ ref('fct_finance_bank_transactions') }}
),
final as (
    select
        bank_account_id,
        toYear(transaction_date)                                    as transaction_year,
        toMonth(transaction_date)                                   as transaction_month,
        count(*)                                                    as nb_transactions,
        sumIf(amount, transaction_type = 'debit')                   as total_debit,
        sumIf(amount, transaction_type = 'credit')                  as total_credit,
        sumIf(amount, transaction_type = 'credit')
            - sumIf(amount, transaction_type = 'debit')             as net_flow,
        countIf(is_reconciled = true)                               as nb_reconciled,
        countIf(is_reconciled = false)                              as nb_unreconciled
    from txns
    group by bank_account_id, toYear(transaction_date), toMonth(transaction_date)
)
select * from final
