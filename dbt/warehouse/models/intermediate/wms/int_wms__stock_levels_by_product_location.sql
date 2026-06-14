{{ config(materialized='ephemeral', tags=['intermediate', 'wms']) }}

with stock_movements as (
    select * from {{ ref('stg_wms__stock_movements') }}
)

select
    product_id,
    location_id,
    warehouse_id,
    sumIf(quantity, movement_type = 'receipt')                       as total_received,
    sumIf(quantity, movement_type = 'shipment')                      as total_shipped,
    sumIf(quantity, movement_type = 'adjustment')                    as total_adjusted,
    sumIf(quantity, movement_type = 'receipt')
        - sumIf(quantity, movement_type = 'shipment')
        + sumIf(quantity, movement_type = 'adjustment')              as current_stock,
    max(moved_at)                                                    as last_movement_at
from stock_movements
group by
    product_id,
    location_id,
    warehouse_id
