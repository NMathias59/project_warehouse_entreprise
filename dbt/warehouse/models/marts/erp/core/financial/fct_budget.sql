{{
config(
    materialized='table',
    tags=['core', 'erp', 'fct', 'finance']
)
}}

with budget as (

    select
        id_budget,
        label,
        created_at,
        is_active
    from {{ ref('stg_erp__budgets') }}

),

budget_line as (

    select
        id_budget_line,
        budget_id,
        account_number,
        amount
    from {{ ref('stg_erp__budget_lines') }}

)

select
    b.id_budget as id_budget,
    b.label as name,
    b.created_at as created_at,
    b.is_active as is_active,
    bl.id_budget_line,
    bl.account_number,
    bl.amount
from budget as b
left join budget_line as bl on b.id_budget = bl.budget_id