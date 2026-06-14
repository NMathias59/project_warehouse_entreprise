{{ config(materialized='table', engine='MergeTree()', order_by='(id_department)', tags=['marts','sirh','dim']) }}
with source as (select * from {{ ref('stg_sirh__departments') }})
select * from source where is_active = true
