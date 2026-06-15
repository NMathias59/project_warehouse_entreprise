{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(production_order_id)',
    tags=['reports', 'mes', 'production']
) }}

select
    d.production_order_id,
    po.reference,
    po.product_id,
    po.status,
    d.nb_defects_total,
    d.nb_defects_minor,
    d.nb_defects_major,
    d.nb_defects_critical,
    d.total_defective_qty,
    d.total_reworkable_qty,
    d.first_defect_at,
    d.last_defect_at,
    po.scrap_rate
from {{ ref('fct_mes_defects') }} as d
left join {{ ref('fct_mes_production_orders') }} as po
    on po.id_production_order = d.production_order_id
