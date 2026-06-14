{{ config(materialized='table', engine='MergeTree()', order_by='(id_certification)', tags=['marts','qms','fct']) }}
with source as (select * from {{ ref('stg_qms__certifications') }})
select * from source
