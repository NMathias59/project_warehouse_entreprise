{{ config(materialized='table', engine='MergeTree()', order_by='(id_position)', tags=['marts','sirh','dim']) }}
with source as (select * from {{ ref('stg_sirh__positions') }})
select * from source where is_active = true
