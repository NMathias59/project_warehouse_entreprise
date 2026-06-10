{{ config(materialized='table', tags=['mart','erp','core','catalog']) }}


select
    component_id as id_component,
    component_name,
    unit,
    is_active,
    max_stock,
    min_stock,
    current_stock,
    location_id,
    stock_updated_at

from {{ ref('int_erp__component_stock_status') }}