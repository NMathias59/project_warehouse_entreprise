{{
    config(
        materialized='table',
        tags=['mart', 'erp', 'core', 'procurement']
    )
}}

select
    status,
    nb_orders,
    total_ht
from {{ ref('int_erp__purchase_order_status_stats') }}

