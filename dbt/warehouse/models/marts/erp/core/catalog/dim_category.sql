{{ config(materialized='table', tags=['mart','erp','core','catalog']) }}

SELECT
    id_category,
    name,
    created_at
FROM {{ ref('stg_erp__categories') }}