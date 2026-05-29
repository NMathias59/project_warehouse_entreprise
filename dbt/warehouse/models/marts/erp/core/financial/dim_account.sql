{{
config(
    materialized='table',
    tags=['core','mart','dim','account','erp','financial']
)
}}
-- Dim an account model for ERP, sourced from the chart of accounts. This model will be used in financial reporting and analysis to categorize and summarize financial transactions based on account types and codes.
select
    id_chart_of_account as id_account,
    account_number as account_code,
    account_type as account_type
from {{ref('stg_erp__chart_of_accounts')}}