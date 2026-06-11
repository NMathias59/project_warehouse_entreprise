{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(pc_model_id, id_bom_header)',
    tags=['marts', 'erp', 'production']
) }}

select
    bh.id_bom_header,
    bh.pc_model_id,
    pm.name                                     as pc_model_name,
    pm.code                                     as pc_model_code,
    bh.version,
    bh.is_current,
    bh.notes,
    bh.created_at,
    count(bl.id_bom_line)                       as nb_components,
    count(distinct bl.component_id)             as nb_distinct_components,
    sum(bl.quantity)                            as total_qty_components
from {{ ref('stg_erp__bom_headers') }} as bh
left join {{ ref('stg_erp__bom_lines') }} as bl
    on bl.bom_header_id = bh.id_bom_header
left join {{ ref('stg_erp__pc_models') }} as pm
    on pm.id_pc_model = bh.pc_model_id
group by
    bh.id_bom_header, bh.pc_model_id, pm.name, pm.code,
    bh.version, bh.is_current, bh.notes, bh.created_at
