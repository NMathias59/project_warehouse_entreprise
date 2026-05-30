{{ config(materialized='table', tags=['mart','erp','core']) }}

select
    id_department,
    code,
    name
from {{ ref('stg_erp__departments') }}