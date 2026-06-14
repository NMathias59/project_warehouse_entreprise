{{ config(materialized='table', engine='MergeTree()', order_by='(id_technician)', tags=['marts','sav','dim']) }}
with technicians as (
    select * from {{ ref('stg_sav__technicians') }}
)
select
    id_technician, code, first_name, last_name, email, phone, specialization, is_active, created_at, updated_at, _etl_loaded_at
from technicians
where is_active = true
