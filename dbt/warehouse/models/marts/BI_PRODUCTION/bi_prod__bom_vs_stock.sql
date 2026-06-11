{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(pc_model_id, component_id)',
    tags=['bi', 'production']
) }}

select
    bom.id_bom_header,
    bom.pc_model_id,
    bom.pc_model_name,
    bom.pc_model_code,
    bom.version,
    bom.is_current,
    bl.id_bom_line,
    bl.component_id,
    bl.position,
    bl.quantity                                                         as qty_required_per_unit,
    c.component_name,
    c.unit,
    coalesce(c.current_stock, 0)                                        as current_stock,
    coalesce(c.min_stock, 0)                                            as min_stock,
    coalesce(c.max_stock, 0)                                            as max_stock,
    if(bl.quantity > 0,
       floor(coalesce(c.current_stock, 0) / bl.quantity),
       null)                                                            as producible_units,
    if(coalesce(c.current_stock, 0) < bl.quantity, 1, 0)              as is_blocking,
    greatest(bl.quantity - coalesce(c.current_stock, 0), 0)            as shortage_qty,
    if(coalesce(c.current_stock, 0) > 0 and bl.quantity > 0,
       round(coalesce(c.current_stock, 0) / bl.quantity, 1),
       0)                                                               as stock_coverage_ratio
from {{ ref('dim_bom') }} as bom
inner join {{ ref('stg_erp__bom_lines') }} as bl
    on bl.bom_header_id = bom.id_bom_header
left join {{ ref('dim_components') }} as c
    on c.id_component = bl.component_id
where bom.is_current = true
