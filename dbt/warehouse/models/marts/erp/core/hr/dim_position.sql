{{ config(materialized='table', tags=['mart','erp','core']) }}

select id_position,
       title
from {{ ref('stg_erp__positions') }}