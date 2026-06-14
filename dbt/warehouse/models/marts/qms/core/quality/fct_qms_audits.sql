{{ config(materialized='table', engine='MergeTree()', order_by='(id_audit, planned_at)', tags=['marts','qms','fct']) }}
with source as (select * from {{ ref('int_qms__audit_results_aggregated') }})
select * from source
