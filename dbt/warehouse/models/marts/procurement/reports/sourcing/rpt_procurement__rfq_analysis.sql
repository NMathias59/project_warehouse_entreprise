{{ config(materialized='table', engine='MergeTree()', order_by='(rfq_id, price_rank)', tags=['reports','procurement','sourcing']) }}
with source as (
    select * from {{ ref('fct_procurement_rfq_responses') }}
)
select * from source
