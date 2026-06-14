{{ config(materialized='table', engine='MergeTree()', order_by='(survey_type)', tags=['marts','sav','fct']) }}
with source as (
    select * from {{ ref('int_sav__satisfaction_aggregated') }}
)
select * from source
