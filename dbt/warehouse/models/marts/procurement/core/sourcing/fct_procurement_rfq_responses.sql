{{ config(materialized='table', engine='MergeTree()', order_by='(rfq_id, price_rank)', tags=['marts','procurement','fct']) }}
with source as (select * from {{ ref('int_procurement__rfq_responses_ranked') }})
select * from source
