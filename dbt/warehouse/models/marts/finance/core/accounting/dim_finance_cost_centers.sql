{{ config(materialized='table', engine='MergeTree()', order_by='(id_cost_center)', tags=['marts','finance','dim']) }}
with source as (select * from {{ ref('stg_finance__cost_centers') }})
select * from source where is_active = true
