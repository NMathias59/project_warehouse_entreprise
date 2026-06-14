{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(actual_start_at, work_center_id)',
    tags=['reports', 'mes', 'production']
) }}

with production_orders as (
    select
        id_production_order,
        reference,
        status,
        product_id,
        work_center_id,
        quantity_planned,
        quantity_produced,
        quantity_scrapped,
        scrap_rate,
        yield_rate,
        total_actual_minutes,
        nb_defects,
        actual_start_at,
        actual_end_at
    from {{ ref('fct_mes_production_orders') }}
),

work_centers as (
    select
        id_work_center,
        name,
        work_center_type,
        capacity_per_hour
    from {{ ref('dim_mes_work_centers') }}
),

final as (
    select
        po.id_production_order,
        po.reference,
        po.status,
        po.product_id,
        po.work_center_id,
        wc.name,
        wc.work_center_type,
        wc.capacity_per_hour,
        po.quantity_planned,
        po.quantity_produced,
        po.quantity_scrapped,
        po.scrap_rate,
        po.yield_rate,
        po.total_actual_minutes,
        po.nb_defects,
        po.actual_start_at,
        po.actual_end_at
    from production_orders as po
    left join work_centers as wc on wc.id_work_center = po.work_center_id
)

select * from final
