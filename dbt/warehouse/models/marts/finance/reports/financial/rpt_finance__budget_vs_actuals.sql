{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(account_id, period_number)',
    settings={'allow_nullable_key': 1},
    tags=['reports','finance','financial']
) }}

with budget as (
    select budget_id, account_id, cost_center_id, period_number, amount as budget_amount
    from {{ ref('fct_finance_budget_lines') }}
),
journal as (
    select account_id, cost_center_id, toMonth(entry_date) as period_number,
           sum(net_amount) as actual_amount
    from {{ ref('fct_finance_journal_lines') }}
    group by account_id, cost_center_id, toMonth(entry_date)
),
accounts as (
    select id_account, account_number, label as account_label, account_type
    from {{ ref('dim_finance_accounts') }}
),
final as (
    select
        b.budget_id                                                             as budget_id,
        b.account_id                                                            as account_id,
        a.account_number                                                        as account_number,
        a.account_label                                                         as account_label,
        a.account_type                                                          as account_type,
        b.cost_center_id                                                        as cost_center_id,
        b.period_number                                                         as period_number,
        b.budget_amount                                                         as budget_amount,
        coalesce(j.actual_amount, 0)                                            as actual_amount,
        b.budget_amount - coalesce(j.actual_amount, 0)                          as variance,
        (b.budget_amount - coalesce(j.actual_amount, 0))
            / nullIf(b.budget_amount, 0) * 100                                  as variance_pct,
        if(coalesce(j.actual_amount, 0) > b.budget_amount, true, false)         as is_over_budget
    from budget as b
    left join journal  as j on j.account_id     = b.account_id
                            and j.cost_center_id = b.cost_center_id
                            and j.period_number  = b.period_number
    left join accounts as a on a.id_account = b.account_id
)
select * from final
