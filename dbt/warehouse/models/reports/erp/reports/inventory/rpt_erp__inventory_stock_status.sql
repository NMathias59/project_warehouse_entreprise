{{ config(
    materialized='table',
    tags=['reports', 'erp', 'inventory']
) }}

with stock as (

    select
        stock_id,
        product_id,
        location_id,
        quantity,
        updated_at
    from {{ ref('fct_stock_level') }}

),

components as (

    select
        id_component,
        component_name,
        unit,
        is_active,
        min_stock,
        max_stock,
        current_stock
    from {{ ref('dim_components') }}

),

warehouses as (

    select
        id_warehouse,
        name    as warehouse_name,
        code    as warehouse_code,
        is_active as warehouse_is_active
    from {{ ref('dim_warehouses') }}

),

final as (

    select
        s.stock_id,
        s.product_id,
        c.component_name,
        c.unit,
        c.is_active                                                 as component_is_active,
        s.location_id,
        w.warehouse_name,
        w.warehouse_code,
        w.warehouse_is_active,
        s.quantity                                                  as stock_quantity,
        c.min_stock,
        c.max_stock,
        c.current_stock                                             as component_total_stock,
        if(c.min_stock > 0, s.quantity - c.min_stock, null)        as stock_vs_min,
        if(s.quantity < c.min_stock, 1, 0)                         as is_below_min,
        if(s.quantity = 0, 1, 0)                                   as is_out_of_stock,
        if(s.quantity > c.max_stock, 1, 0)                         as is_above_max,
        if(c.min_stock > 0,
           round(s.quantity / c.min_stock * 100, 1),
           null)                                                    as stock_coverage_pct,
        s.updated_at
    from stock s
    left join components c on s.product_id  = c.id_component
    left join warehouses w  on s.location_id = w.id_warehouse

)

select * from final
