{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(product_id, location_id)',
    tags=['reports', 'wms', 'operations']
) }}

with stock_levels as (
    select
        product_id,
        location_id,
        current_stock,
        total_received,
        total_shipped,
        last_movement_at
    from {{ ref('fct_wms_stock_levels') }}
),

locations as (
    select
        id_location,
        warehouse_id,
        code,
        zone,
        aisle,
        rack
    from {{ ref('dim_wms_locations') }}
),

final as (
    select
        s.product_id,
        s.location_id,
        l.warehouse_id,
        l.code,
        l.zone,
        l.aisle,
        l.rack,
        s.current_stock,
        s.total_received,
        s.total_shipped,
        s.last_movement_at
    from stock_levels as s
    left join locations as l on l.id_location = s.location_id
)

select * from final
