{{ config(materialized='table', tags=['mart', 'erp', 'core']) }}

select
    component_id,
    component_name,
    min_stock,
    total_stock,
    is_below_min
from {{ ref('int_erp__component_stock_alerts') }}

