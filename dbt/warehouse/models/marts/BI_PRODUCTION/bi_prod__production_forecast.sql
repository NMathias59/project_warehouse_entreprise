{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='tuple()',
    tags=['bi', 'production']
) }}

with upcoming_work_orders as (

    select
        id_work_order,
        reference,
        status,
        qty_planned,
        pc_model_id,
        pc_model_name,
        pc_model_code,
        planned_at,
        dateDiff('day', today(), toDate(planned_at))                     as days_until_planned
    from {{ ref('fct_work_orders') }}
    where status in ('pending', 'in_progress')
      and planned_at > toDateTime('1970-01-01 00:00:00')

),

bom_coverage as (

    select
        wo.id_work_order,
        wo.reference,
        wo.status,
        wo.qty_planned,
        wo.pc_model_id,
        wo.pc_model_name,
        wo.pc_model_code,
        wo.planned_at,
        wo.days_until_planned,
        bvs.component_id,
        bvs.component_name,
        bvs.unit,
        bvs.qty_required_per_unit,
        bvs.qty_required_per_unit * wo.qty_planned                       as total_qty_required,
        bvs.current_stock,
        greatest(
            bvs.qty_required_per_unit * wo.qty_planned - bvs.current_stock,
            0
        )                                                                as projected_shortage,
        if(bvs.current_stock >= bvs.qty_required_per_unit * wo.qty_planned,
           1, 0)                                                         as component_covered
    from upcoming_work_orders as wo
    inner join {{ ref('bi_prod__bom_vs_stock') }} as bvs
        on bvs.pc_model_id = wo.pc_model_id

)

select
    id_work_order,
    reference,
    status,
    qty_planned,
    pc_model_id,
    pc_model_name,
    pc_model_code,
    planned_at,
    days_until_planned,
    count(component_id)                                                   as nb_components_required,
    countIf(component_covered = 1)                                        as nb_components_covered,
    countIf(component_covered = 0)                                        as nb_components_short,
    if(countIf(component_covered = 0) = 0, 1, 0)                         as is_fully_coverable,
    sum(total_qty_required)                                               as total_components_required,
    sum(projected_shortage)                                               as total_projected_shortage,
    groupArrayIf(component_name, component_covered = 0)                   as blocking_components
from bom_coverage
group by
    id_work_order,
    reference,
    status,
    qty_planned,
    pc_model_id,
    pc_model_name,
    pc_model_code,
    planned_at,
    days_until_planned
