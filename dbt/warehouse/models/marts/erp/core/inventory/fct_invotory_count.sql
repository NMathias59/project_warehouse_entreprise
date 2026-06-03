{{ config(materialized='table', tags=['mart','erp','core','invotory']) }}

with ic as (
    select * from {{ ref('stg_erp__inventory_counts') }}
),
icl as (
    select * from {{ ref('stg_erp__inventory_count_lines') }}
)

select
    ic.id_inventory_count,
    ic.started_at,
    ic.warehouse_id,
    ic.created_at,
    icl.id_inventory_count_line,
    icl.component_id,
    coalesce(icl.counted_qty, 0)    as counted_qty,
    coalesce(icl.expected_qty, 0)   as expected_qty,
    coalesce(icl.variance, 0)       as variance,
    icl.counted_at,
    icl.location_id
from icl
left join ic on ic.id_inventory_count = icl.inventory_count_id
