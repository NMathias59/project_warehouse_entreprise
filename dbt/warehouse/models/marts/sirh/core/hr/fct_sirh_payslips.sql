{{ config(materialized='table', engine='MergeTree()', order_by='(employee_id, pay_period_year, pay_period_month)', tags=['marts','sirh','fct']) }}
with source as (select * from {{ ref('stg_sirh__payslips') }})
select * from source
