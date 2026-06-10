{{
config(
    materialized='table',
    tags=['core','mart','dim','erp','financial']
)
}}
-- Dimension: Budget Line 1 1:M Budget model, sourced from the ERP system. This model will be used in financial reporting and analysis to categorize and summarize financial transactions based on budget lines, including details such as account number, amount, and associated budget.
select id_budget_line,
       budget_id,
       account_number,
       amount
from {{ ref('stg_erp__budget_lines') }}