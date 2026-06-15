{{ config(materialized='view', tags=['intermediate', 'plm']) }}

select
    bl.id_bom_line              as id_bom_line,
    bh.id_bom_header            as id_bom,
    bh.product_version_id       as product_version_id,
    bh.bom_type                 as bom_type,
    bh.status                   as bom_status,
    bl.parent_component_id      as parent_component_id,
    bl.component_code           as component_code,
    bl.component_name           as component_name,
    bl.component_type           as component_type,
    bl.quantity                 as quantity,
    bl.unit_of_measure          as unit_of_measure,
    bl.is_critical              as is_critical,
    bl.lead_time_days           as lead_time_days
from {{ ref('stg_plm__bom_headers') }} as bh
left join {{ ref('stg_plm__bom_lines') }} as bl
    on bl.bom_id = bh.id_bom_header
