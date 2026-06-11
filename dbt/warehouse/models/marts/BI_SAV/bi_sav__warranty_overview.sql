{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(supplier_id, component_id)',
    tags=['bi', 'sav']
) }}

select
    w.id_warranty,
    w.type                                                              as warranty_type,
    w.created_at                                                        as warranty_start,
    w.duration_months,
    addMonths(toDate(w.created_at), w.duration_months)                  as warranty_expires_at,
    w.supplier_id,
    s.supplier_name,
    w.component_id,
    c.component_name,
    c.unit,
    if(addMonths(toDate(w.created_at), w.duration_months) >= today(), 1, 0) as is_active,
    dateDiff('day', today(),
             addMonths(toDate(w.created_at), w.duration_months))        as days_until_expiry,
    multiIf(
        addMonths(toDate(w.created_at), w.duration_months) < today(),   'expired',
        dateDiff('day', today(),
                 addMonths(toDate(w.created_at), w.duration_months)) <= 30,  'expiring_30d',
        dateDiff('day', today(),
                 addMonths(toDate(w.created_at), w.duration_months)) <= 90,  'expiring_90d',
        'active'
    )                                                                   as warranty_status
from {{ ref('stg_erp__warranties') }} as w
left join {{ ref('dim_suppliers') }} as s
    on s.id_supplier = w.supplier_id
left join {{ ref('dim_components') }} as c
    on c.id_component = w.component_id
