{{ config(materialized='table', tags=['mart','erp','core']) }}

select
    id_warehouse_location as id_warehouse_location,
    warehouse_id,
    code,
    coalesce(code, bin, '') as name,
    created_at
from {{ ref('stg_erp__warehouse_locations') }}
