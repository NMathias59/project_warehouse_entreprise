{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='tuple()',
    tags=['bi', 'finance']
) }}

select
    toDate(transaction_date)                                            as txn_date,
    toYYYYMM(toDate(transaction_date))                                  as transaction_month,
    bank_account_id,
    count(id_bank_transaction)                                          as nb_transactions,
    countIf(is_reconciled = true)                                       as nb_reconciled,
    countIf(is_reconciled = false)                                      as nb_unreconciled,
    sumIf(amount, amount > 0)                                           as total_inflows,
    sumIf(abs(amount), amount < 0)                                      as total_outflows,
    sum(amount)                                                         as net_cash_flow,
    max(balance)                                                        as closing_balance,
    if(count(id_bank_transaction) > 0,
       round(countIf(is_reconciled = true) * 100.0 / count(id_bank_transaction), 2),
       0)                                                               as reconciliation_rate_pct
from {{ ref('fct_bank_transactions') }}
where transaction_date is not null
group by toDate(transaction_date), bank_account_id
