{{ config(materialized='table', engine='MergeTree()', order_by='(id_fiscal_year)', tags=['marts','finance','dim']) }}
with source as (select * from {{ ref('stg_finance__fiscal_years') }})
select * from source
