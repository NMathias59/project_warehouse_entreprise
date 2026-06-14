{{ config(materialized='table', engine='MergeTree()', order_by='(employee_id, review_period_year)', tags=['marts','sirh','fct']) }}
with source as (select * from {{ ref('stg_sirh__performance_reviews') }})
select * from source
