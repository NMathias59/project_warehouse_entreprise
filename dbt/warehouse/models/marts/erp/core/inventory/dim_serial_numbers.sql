{{ config(materialized='table', tags=['mart','erp','core']) }}

select
    id_serial_number as id_serial_number,
    serial,
    status,
    coalesce(shipped_at, produced_at, toDateTime('1970-01-01 00:00:00')) as shipped_at,
    produced_at,
    work_order_id
from {{ ref('stg_erp__serial_numbers') }}