{{ config(
    materialized='table',
    tags=['reports', 'erp', 'inventory']
) }}

with movements as (

    select
        id_stock_movement,
        movement_type,
        component_id,
        quantity,
        location_id,
        created_at,
        reference
    from {{ ref('fct_component_stock_movement') }}

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
        name as warehouse_name,
        code as warehouse_code
    from {{ ref('dim_warehouses') }}

),

final as (

    select
        m.id_stock_movement,
        m.movement_type,
        m.component_id,
        c.component_name,
        c.unit,
        c.is_active                                                 as component_is_active,
        c.current_stock,
        c.min_stock,
        c.max_stock,
        m.quantity,
        if(m.movement_type = 'out', -m.quantity, m.quantity)       as signed_quantity,
        m.location_id,
        w.warehouse_name,
        w.warehouse_code,
        m.reference,
        toDate(m.created_at)                                        as movement_date,
        toYYYYMM(toDate(m.created_at))                              as movement_month,
        toDayOfWeek(toDate(m.created_at))                           as movement_day_of_week,
        m.created_at
    from movements m
    left join components c on m.component_id = c.id_component
    left join warehouses w  on m.location_id  = w.id_warehouse

)

select * from final
