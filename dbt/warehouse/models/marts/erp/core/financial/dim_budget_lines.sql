{{
    config(
        materialized='table',
        tags=['mart', 'erp', 'core', 'financial']
    )
}}

select
    id_budget_line,
    budget_id,
    account_number,
    amount
from {{ ref('stg_erp__budget_lines') }}