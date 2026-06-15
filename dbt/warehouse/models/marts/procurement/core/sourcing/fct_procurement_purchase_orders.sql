{{ config(materialized='table', engine='MergeTree()', order_by='(id_purchase_order_line, sent_at)', settings={'allow_nullable_key': 1}, tags=['marts','procurement','fct']) }}
with source as (select * from {{ ref('int_procurement__purchase_orders_with_lines') }})
select * from source
