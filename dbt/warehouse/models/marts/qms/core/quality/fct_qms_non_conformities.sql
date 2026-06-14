{{ config(materialized='table', engine='MergeTree()', order_by='(id_non_conformity, detected_at)', tags=['marts','qms','fct']) }}
with source as (select * from {{ ref('int_qms__non_conformities_with_actions') }})
select * from source
