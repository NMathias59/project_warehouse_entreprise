{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(campaign_id)',
    tags=['marts', 'marketing', 'fct']
) }}

with source as (
    select * from {{ ref('int_marketing__email_funnel_by_campaign') }}
)

select
    *
from source
