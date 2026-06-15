{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(id_production_order, actual_start_at)',
    settings={'allow_nullable_key': 1},
    tags=['marts', 'mes', 'fct']
) }}

with source as (
    select * from {{ ref('int_mes__production_orders_with_stats') }}
)

select
    *
from source
