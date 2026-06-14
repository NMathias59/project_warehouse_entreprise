{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(campaign_id, date)',
    tags=['marts', 'marketing', 'fct']
) }}

with source as (
    select * from {{ ref('stg_marketing__ad_performance') }}
)

select
    *
from source
