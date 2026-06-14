{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(work_center_id, recorded_at)',
    tags=['marts', 'mes', 'fct']
) }}

with source as (
    select * from {{ ref('stg_mes__time_records') }}
)

select
    *
from source
