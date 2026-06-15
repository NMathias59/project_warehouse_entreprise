{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(shipped_at)',
    settings={'allow_nullable_key': 1},
    tags=['reports', 'wms', 'operations']
) }}

select
    s.id_shipment,
    any(s.reference)            as reference,
    any(s.status)               as status,
    any(s.warehouse_id)         as warehouse_id,
    any(s.shipped_at)           as shipped_at,
    count()                     as nb_lines,
    any(p.completion_rate)      as completion_rate,
    any(p.duration_minutes)     as duration_minutes
from {{ ref('fct_wms_shipments') }} as s
left join {{ ref('fct_wms_picking_orders') }} as p
    on p.shipment_id = s.id_shipment
group by
    s.id_shipment
