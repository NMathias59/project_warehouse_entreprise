{{ config(materialized='table', engine='MergeTree()', order_by='(id_employee)', tags=['marts','sirh','dim']) }}
with source as (
    select * from {{ ref('int_sirh__employees_with_contract') }}
)
select * from source
