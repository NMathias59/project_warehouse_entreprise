{{ config(materialized='view', tags=['intermediate', 'finance']) }}

select
    bl.budget_id                                                    as budget_id,
    bl.account_id                                                   as account_id,
    bl.cost_center_id                                               as cost_center_id,
    bl.period_number                                                as period_number,
    bl.amount                                                       as budget_amount,
    coalesce(a.actual_amount, 0)                                    as actual_amount,
    bl.amount - coalesce(a.actual_amount, 0)                        as variance,
    (bl.amount - coalesce(a.actual_amount, 0))
        / nullIf(bl.amount, 0) * 100                                as variance_pct,
    if(coalesce(a.actual_amount, 0) > bl.amount, true, false)       as is_over_budget
from {{ ref('stg_finance__budget_lines') }} as bl
left join (
    select
        jl.account_id                               as account_id,
        jl.cost_center_id                           as cost_center_id,
        toMonth(je.entry_date)                      as period_month,
        sum(jl.debit_amount - jl.credit_amount)     as actual_amount
    from {{ ref('stg_finance__journal_lines') }} as jl
    left join {{ ref('stg_finance__journal_entries') }} as je
        on je.id_journal_entry = jl.journal_entry_id
    group by
        account_id,
        cost_center_id,
        period_month
) as a
    on  a.account_id     = bl.account_id
    and a.cost_center_id = bl.cost_center_id
    and a.period_month   = bl.period_number
