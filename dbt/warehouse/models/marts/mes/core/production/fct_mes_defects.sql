{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(production_order_id)',
    tags=['marts', 'mes', 'fct']
) }}

with source as (
    select * from {{ ref('int_mes__defects_aggregated_by_order') }}
)

select
    *
from source
