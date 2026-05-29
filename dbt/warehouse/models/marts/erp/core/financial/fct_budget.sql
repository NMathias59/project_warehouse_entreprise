{{
config(
    materialized='table',
    tags=['core', 'erp', 'fct', 'finance']
)
}}

-- FCT Budget model for ERP, sourced from the budgets and budget lines. This model will be used in financial reporting and analysis to summarize budget information, including total amounts by budget and associated account numbers.

with budget as (
    select * from {{ ref('stg_erp__budgets') }}
),
budget_line as (
select * from {{ ref('stg_erp__budget_lines') }}
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