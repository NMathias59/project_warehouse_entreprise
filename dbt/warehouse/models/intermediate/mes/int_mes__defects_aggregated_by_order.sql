{{ config(materialized='ephemeral', tags=['intermediate', 'mes']) }}

with defects as (
    select * from {{ ref('stg_mes__defects') }}
)

select
    production_order_id,
    count(id_defect)                                    as nb_defects_total,
    countIf(severity = 'minor')                         as nb_defects_minor,
    countIf(severity = 'major')                         as nb_defects_major,
    countIf(severity = 'critical')                      as nb_defects_critical,
    sum(quantity_defective)                             as total_defective_qty,
    sumIf(quantity_defective, is_reworkable)            as total_reworkable_qty,
    min(detected_at)                                    as first_defect_at,
    max(detected_at)                                    as last_defect_at
from defects
group by
    production_order_id
