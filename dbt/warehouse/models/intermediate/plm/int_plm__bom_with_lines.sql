{{ config(materialized='ephemeral', tags=['intermediate', 'plm']) }}

with bom_headers as (
    select * from {{ ref('stg_plm__bom_headers') }}
),

bom_lines as (
    select * from {{ ref('stg_plm__bom_lines') }}
)

select
    bl.id_bom_line,
    bh.id_bom,
    bh.product_version_id,
    bh.bom_type,
    bh.bom_status,
    bl.parent_component_id,
    bl.component_code,
    bl.component_name,
    bl.component_type,
    bl.quantity,
    bl.unit_of_measure,
    bl.is_critical,
    bl.lead_time_days
from bom_headers as bh
left join bom_lines as bl
    on bl.bom_id = bh.id_bom
