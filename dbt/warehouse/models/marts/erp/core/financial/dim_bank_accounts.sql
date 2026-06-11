{{
    config(
        materialized='table',
        tags=['mart', 'erp', 'core', 'financial']
    )
}}

select
    id_bank_account,
    name,
    iban,
    currency,
    is_active,
    created_at
from {{ ref('stg_erp__bank_accounts') }}