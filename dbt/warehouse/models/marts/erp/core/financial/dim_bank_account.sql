{{
config(
    materialized='table',
    tags=['core','mart','dim','account','erp','financial']
)
}}
-- Bank Accounts 1: M with Bank model, sourced from the ERP system. This model will be used in financial reporting and analysis to categorize and summarize financial transactions based on bank accounts, including details such as account name, IBAN, currency, and active status.
select id_bank_account,
       name,
       iban,
       currency,
       is_active,
       created_at
from {{ref('stg_erp__bank_accounts')}}