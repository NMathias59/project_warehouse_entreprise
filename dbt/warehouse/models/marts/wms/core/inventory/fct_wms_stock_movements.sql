{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(product_id, moved_at)',
    tags=['marts', 'wms', 'fct']
) }}

with source as (
    select * from {{ ref('stg_wms__stock_movements') }}
)

select
    *
from source
