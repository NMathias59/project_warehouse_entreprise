{{ config(materialized='table', engine='MergeTree()', order_by='(id_change_request, submitted_at)', tags=['marts','plm','fct']) }}
with source as (select * from {{ ref('stg_plm__change_requests') }})
select * from source
