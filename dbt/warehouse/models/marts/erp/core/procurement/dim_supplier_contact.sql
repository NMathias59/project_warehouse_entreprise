{{ config(materialized='table', tags=['mart','erp','core', 'procurement']) }}

select
    id_supplier_contact as id_supplier_contact,
    first_name,
    last_name,
    role,
    email,
    phone,
    supplier_id
from {{ ref('stg_erp__supplier_contacts') }}

