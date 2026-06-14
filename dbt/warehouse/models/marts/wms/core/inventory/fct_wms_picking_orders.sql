{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(id_picking_order)',
    tags=['marts', 'wms', 'fct']
) }}

with source as (
    select * from {{ ref('int_wms__picking_performance') }}
)

select
    *
from source
