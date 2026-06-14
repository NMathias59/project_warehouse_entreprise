{{ config(materialized='table', engine='MergeTree()', order_by='(supplier_id, evaluation_year)', tags=['marts','qms','fct']) }}
with source as (select * from {{ ref('int_qms__supplier_quality_by_period') }})
select * from source
