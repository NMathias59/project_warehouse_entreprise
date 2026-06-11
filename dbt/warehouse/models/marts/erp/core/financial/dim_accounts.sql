{{
    config(
        materialized='table',
        tags=['mart', 'erp', 'core', 'financial']
    )
}}

select
    id_chart_of_account as id_account,
    account_number as account_code,
    account_type as account_type
from {{ ref('stg_erp__chart_of_accounts') }}