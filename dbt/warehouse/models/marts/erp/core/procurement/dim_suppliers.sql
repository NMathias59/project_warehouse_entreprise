{{ config(materialized='table', tags=['mart', 'erp', 'core', 'procurement']) }}

select
    id_supplier,
    supplier_name,
    country,
    is_active,
    nb_purchase_orders,
    total_purchase_ht
from {{ ref('int_erp__supplier_stats') }}

