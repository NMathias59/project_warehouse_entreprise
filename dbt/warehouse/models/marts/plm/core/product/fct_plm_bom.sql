{{ config(materialized='table', engine='MergeTree()', order_by='(bom_id, id_bom_line)', tags=['marts','plm','fct']) }}
with source as (select * from {{ ref('int_plm__bom_with_lines') }})
select * from source
