{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(id_audience)',
    tags=['marts', 'marketing', 'dim']
) }}

with audiences as (
    select * from {{ ref('stg_marketing__audiences') }}
)

select
    *
from audiences
