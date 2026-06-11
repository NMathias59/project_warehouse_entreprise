{{ config(materialized='table', tags=['mart','erp','core','catalog']) }}

with components as (

    select
        id_components,
        name,
        unit,
        is_active,
        max_stock,
        min_stock
    from {{ ref('stg_erp__components') }}

),

stock as (

    select
        component_id,
        sum(quantity)    as current_stock,
        max(location_id) as location_id,
        max(updated_at)  as stock_updated_at
    from {{ ref('stg_erp__component_stock') }}
    group by component_id

),

final as (

    select
        components.id_components  as id_component,
        components.name           as component_name,
        components.unit,
        components.is_active,
        components.max_stock,
        components.min_stock,
        stock.current_stock,
        stock.location_id,
        stock.stock_updated_at
    from components
    left join stock on components.id_components = stock.component_id

)

select * from final