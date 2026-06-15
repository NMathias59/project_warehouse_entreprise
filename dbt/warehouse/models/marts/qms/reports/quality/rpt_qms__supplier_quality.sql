{{ config(materialized='table', engine='MergeTree()', order_by='(supplier_id, evaluation_period_year)', tags=['reports','qms','quality']) }}
with source as (
    select * from {{ ref('fct_qms_supplier_quality') }}
)
select * from source
