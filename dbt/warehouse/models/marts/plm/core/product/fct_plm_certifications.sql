{{ config(materialized='table', engine='MergeTree()', order_by='(id_certification)', tags=['marts','plm','fct']) }}
with source as (select * from {{ ref('stg_plm__certifications') }})
select * from source
