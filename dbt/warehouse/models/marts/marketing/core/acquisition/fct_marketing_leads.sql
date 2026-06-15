{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(id_lead, created_at)',
    settings={'allow_nullable_key': 1},
    tags=['marts', 'marketing', 'fct']
) }}

with source as (
    select * from {{ ref('int_marketing__leads_with_attribution') }}
)

select
    *
from source
