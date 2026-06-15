{{ config(materialized='table', engine='MergeTree()', order_by='(id_product_version, approved_at)', settings={'allow_nullable_key': 1}, tags=['marts','plm','fct']) }}
with source as (select * from {{ ref('stg_plm__product_versions') }})
select * from source
