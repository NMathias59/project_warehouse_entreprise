{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(shipped_at)',
    tags=['reports', 'wms', 'operations']
) }}

with shipments as (
    select
        id_shipment,
        id_shipment_line,
        reference,
        status,
        warehouse_id,
        shipped_at
    from {{ ref('fct_wms_shipments') }}
),

picking as (
    select
        shipment_id,
        completion_rate,
        duration_minutes
    from {{ ref('fct_wms_picking_orders') }}
),

shipment_agg as (
    select
        id_shipment,
        reference,
        status,
        warehouse_id,
        shipped_at,
        count() as nb_lines
    from shipments
    group by
        id_shipment,
        reference,
        status,
        warehouse_id,
        shipped_at
),

final as (
    select
        s.id_shipment,
        s.reference,
        s.status,
        s.warehouse_id,
        s.shipped_at,
        s.nb_lines,
        p.completion_rate,
        p.duration_minutes
    from shipment_agg as s
    left join picking as p on p.shipment_id = s.id_shipment
)

select * from final
