{{ config(materialized='table', engine='MergeTree()', order_by='(id_intervention, scheduled_at)', tags=['marts','sav','fct']) }}
with source as (
    select * from {{ ref('int_sav__interventions_with_parts') }}
)
select * from source
