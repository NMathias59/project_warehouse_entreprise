{{ config(materialized='table', engine='MergeTree()', order_by='(id_warranty, created_at)', tags=['marts','sav','fct']) }}
with source as (
    select * from {{ ref('stg_sav__warranties') }}
)
select * from source
