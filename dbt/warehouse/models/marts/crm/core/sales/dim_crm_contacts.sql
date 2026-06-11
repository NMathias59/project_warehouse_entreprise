{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(id_contact)',
    tags=['marts', 'crm', 'dim']
) }}

select
    id_contact,
    first_name,
    last_name,
    concat(first_name, ' ', last_name)   as full_name,
    email,
    phone,
    role,
    is_primary,
    account_id,
    source_customer_id,
    source_supplier_id,
    created_at
from {{ ref('stg_crm__contacts') }}
