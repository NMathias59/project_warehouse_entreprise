{{ config(materialized='ephemeral', tags=['intermediate', 'finance']) }}

with budget_lines as (
    select * from {{ ref('stg_finance__budget_lines') }}
),

journal_lines as (
    select * from {{ ref('stg_finance__journal_lines') }}
),

journal_entries as (
    select * from {{ ref('stg_finance__journal_entries') }}
),

actuals as (
    select
        jl.account_id,
        jl.cost_center_id,
        je.period_id,
        sum(jl.debit_amount - jl.credit_amount)    as actual_amount
    from journal_lines as jl
    left join journal_entries as je
        on je.id_journal_entry = jl.journal_entry_id
    group by
        jl.account_id,
        jl.cost_center_id,
        je.period_id
)

select
    bl.budget_id,
    bl.account_id,
    bl.cost_center_id,
    bl.period_number,
    bl.amount                                                                               as budget_amount,
    a.actual_amount,
    bl.amount - a.actual_amount                                                             as variance,
    (bl.amount - a.actual_amount) / nullIf(bl.amount, 0) * 100                             as variance_pct,
    if(a.actual_amount > bl.amount, true, false)                                            as is_over_budget
from budget_lines as bl
left join actuals as a
    on a.account_id = bl.account_id
    and a.cost_center_id = bl.cost_center_id
    and a.period_id = bl.period_number
