{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(account_number)',
    tags=['bi', 'finance']
) }}

with budget_by_account as (

    select
        account_number,
        sum(amount)                                                     as budgeted_amount
    from {{ ref('fct_budget') }}
    group by account_number

),

actual_by_account as (

    select
        account_number,
        sum(debit)                                                      as total_debit,
        sum(credit)                                                     as total_credit,
        sum(debit) - sum(credit)                                        as net_actual,
        count(distinct id_journal_entry)                                as nb_journal_entries
    from {{ ref('fct_journal_entries') }}
    where account_number != ''
    group by account_number

)

select
    coalesce(b.account_number, a.account_number)                        as account_number,
    coalesce(b.budgeted_amount, 0)                                      as budgeted_amount,
    coalesce(a.total_debit, 0)                                          as actual_debit,
    coalesce(a.total_credit, 0)                                         as actual_credit,
    coalesce(a.net_actual, 0)                                           as actual_net,
    coalesce(a.nb_journal_entries, 0)                                   as nb_journal_entries,
    coalesce(b.budgeted_amount, 0) - coalesce(a.net_actual, 0)         as variance,
    if(coalesce(b.budgeted_amount, 0) > 0,
       round(coalesce(a.net_actual, 0) * 100.0 / b.budgeted_amount, 2),
       null)                                                            as execution_rate_pct,
    multiIf(
        coalesce(b.budgeted_amount, 0) = 0,                    'no_budget',
        coalesce(a.net_actual, 0) > b.budgeted_amount,         'over_budget',
        coalesce(a.net_actual, 0) >= b.budgeted_amount * 0.9,  'on_track',
        coalesce(a.net_actual, 0) >= b.budgeted_amount * 0.5,  'in_progress',
        'under_utilized'
    )                                                                   as budget_status
from budget_by_account as b
full outer join actual_by_account as a
    on a.account_number = b.account_number
