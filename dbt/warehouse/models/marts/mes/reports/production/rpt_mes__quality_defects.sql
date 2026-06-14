{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(production_order_id)',
    tags=['reports', 'mes', 'production']
) }}

with defects as (
    select
        production_order_id,
        nb_defects_total,
        nb_defects_minor,
        nb_defects_major,
        nb_defects_critical,
        total_defective_qty,
        total_reworkable_qty,
        first_defect_at,
        last_defect_at
    from {{ ref('fct_mes_defects') }}
),

production_orders as (
    select
        id_production_order,
        reference,
        product_id,
        status,
        scrap_rate
    from {{ ref('fct_mes_production_orders') }}
),

final as (
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
    from defects as d
    left join production_orders as po on po.id_production_order = d.production_order_id
)

select * from final
