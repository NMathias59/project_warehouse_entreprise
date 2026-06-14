{{ config(materialized='table', engine='MergeTree()', order_by='(account_number)', tags=['marts','finance','dim']) }}
with source as (select * from {{ ref('stg_finance__accounts') }})
select * from source where is_active = true
