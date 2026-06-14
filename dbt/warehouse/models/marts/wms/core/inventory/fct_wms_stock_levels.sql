{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(product_id, location_id)',
    tags=['marts', 'wms', 'fct']
) }}

with source as (
    select * from {{ ref('int_wms__stock_levels_by_product_location') }}
)

select
    *
from source
