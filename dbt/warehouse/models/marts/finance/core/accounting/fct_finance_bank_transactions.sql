{{ config(materialized='table', engine='MergeTree()', order_by='(bank_account_id, transaction_date)', tags=['marts','finance','fct']) }}
with source as (select * from {{ ref('stg_finance__bank_transactions') }})
select * from source
