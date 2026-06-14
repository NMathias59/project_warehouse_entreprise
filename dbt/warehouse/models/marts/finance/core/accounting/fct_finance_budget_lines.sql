{{ config(materialized='table', engine='MergeTree()', order_by='(budget_id, account_id, period_number)', tags=['marts','finance','fct']) }}
with source as (select * from {{ ref('stg_finance__budget_lines') }})
select * from source
