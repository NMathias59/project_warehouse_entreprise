{{ config(materialized='table', engine='MergeTree()', order_by='(id_corrective_action, due_at)', tags=['marts','qms','fct']) }}
with source as (select * from {{ ref('stg_qms__corrective_actions') }})
select * from source
