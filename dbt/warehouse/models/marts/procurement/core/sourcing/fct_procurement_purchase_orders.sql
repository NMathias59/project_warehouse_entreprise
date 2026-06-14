{{ config(materialized='table', engine='MergeTree()', order_by='(purchase_order_id, sent_at)', tags=['marts','procurement','fct']) }}
with source as (select * from {{ ref('int_procurement__purchase_orders_with_lines') }})
select * from source
