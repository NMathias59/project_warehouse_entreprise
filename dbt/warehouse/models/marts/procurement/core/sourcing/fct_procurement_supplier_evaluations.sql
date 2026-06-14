{{ config(materialized='table', engine='MergeTree()', order_by='(supplier_id, evaluation_year)', tags=['marts','procurement','fct']) }}
with source as (select * from {{ ref('stg_procurement__supplier_evaluations') }})
select * from source
