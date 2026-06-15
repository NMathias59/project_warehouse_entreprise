{{ config(materialized='table', engine='MergeTree()', order_by='(planned_at)', settings={'allow_nullable_key': 1}, tags=['reports','qms','quality']) }}
with source as (
    select * from {{ ref('fct_qms_audits') }}
)
select * from source
