{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(actual_start_at, work_center_id)',
    settings={'allow_nullable_key': 1},
    tags=['reports', 'mes', 'production']
) }}

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
from {{ ref('fct_mes_production_orders') }} as po
left join {{ ref('dim_mes_work_centers') }} as wc
    on wc.id_work_center = po.work_center_id
