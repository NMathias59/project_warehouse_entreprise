{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='tuple()',
    tags=['bi', 'logistique']
) }}

with erp_stock as (

    select
        'ERP'                                                           as domaine,
        c.id_component                                                  as product_id,
        c.component_name                                                as product_name,
        c.unit,
        coalesce(c.location_id, '')                                     as warehouse_id,
        coalesce(w.name, '')                                            as warehouse_name,
        coalesce(c.current_stock, 0)                                    as quantity,
        0                                                               as reserved,
        coalesce(c.current_stock, 0)                                    as available,
        coalesce(c.min_stock, 0)                                        as min_stock,
        coalesce(c.max_stock, 0)                                        as max_stock,
        if(coalesce(c.current_stock, 0) <= coalesce(c.min_stock, 0)
           and coalesce(c.min_stock, 0) > 0, 1, 0)                    as is_below_min,
        c.stock_updated_at                                              as updated_at
    from {{ ref('dim_components') }} as c
    left join {{ ref('dim_warehouses') }} as w
        on w.id_warehouse = c.location_id
    where c.is_active = true

),

mkt_stock as (

    select
        'MKT'                                                           as domaine,
        sl.stock_level_product_id                                       as product_id,
        coalesce(sl.product_name, sl.stock_level_product_id)            as product_name,
        ''                                                              as unit,
        sl.stock_level_warehouse_id                                     as warehouse_id,
        coalesce(sl.warehouse_name, sl.stock_level_warehouse_id)        as warehouse_name,
        sl.stock_level_quantity                                         as quantity,
        sl.stock_level_reserved                                         as reserved,
        sl.stock_level_available                                        as available,
        0                                                               as min_stock,
        0                                                               as max_stock,
        0                                                               as is_below_min,
        sl.stock_level_updated_at                                       as updated_at
    from {{ ref('fct_stock_levels') }} as sl

)

select * from erp_stock
union all
select * from mkt_stock
