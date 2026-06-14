{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(id_shift)',
    tags=['marts', 'mes', 'dim']
) }}

with shifts as (
    select * from {{ ref('stg_mes__shifts') }}
)

select
    *
from shifts
