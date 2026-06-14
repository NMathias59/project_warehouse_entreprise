{{ config(materialized='table', engine='MergeTree()', order_by='(id_ticket, created_at)', tags=['marts','sav','fct']) }}
with source as (
    select * from {{ ref('int_sav__tickets_with_resolution_stats') }}
)
select * from source
