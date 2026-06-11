{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='tuple()',
    tags=['bi', 'logistique']
) }}

select
    bvs.id_bom_header,
    bvs.pc_model_id,
    bvs.pc_model_name,
    bvs.pc_model_code,
    bvs.component_id,
    bvs.component_name,
    bvs.unit,
    bvs.qty_required_per_unit,
    bvs.current_stock,
    bvs.shortage_qty,
    bvs.producible_units,
    count(po.id_purchase_order_line)                                     as pending_po_lines,
    coalesce(sum(
        if(po.status not in ('received', 'cancelled'), po.quantity, 0)
    ), 0)                                                                as qty_on_order,
    minIf(po.expected_at,
          po.status not in ('received', 'cancelled'))                   as earliest_expected_at,
    if(
        coalesce(sum(
            if(po.status not in ('received', 'cancelled'), po.quantity, 0)
        ), 0) >= bvs.shortage_qty,
        1, 0
    )                                                                    as is_covered_by_po,
    greatest(
        bvs.shortage_qty - coalesce(sum(
            if(po.status not in ('received', 'cancelled'), po.quantity, 0)
        ), 0),
        0
    )                                                                    as residual_shortage_qty
from {{ ref('bi_prod__bom_vs_stock') }} as bvs
left join {{ ref('fct_purchase_orders') }} as po
    on  po.component_id = bvs.component_id
    and po.status not in ('received', 'cancelled')
where bvs.is_blocking = 1
group by
    bvs.id_bom_header,
    bvs.pc_model_id,
    bvs.pc_model_name,
    bvs.pc_model_code,
    bvs.component_id,
    bvs.component_name,
    bvs.unit,
    bvs.qty_required_per_unit,
    bvs.current_stock,
    bvs.shortage_qty,
    bvs.producible_units
