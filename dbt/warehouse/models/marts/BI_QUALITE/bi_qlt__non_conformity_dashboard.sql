{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(id_non_conformity, detected_at)',
    settings={'allow_nullable_key': 1},
    tags=['bi', 'qualite']
) }}

select
    nc.id_non_conformity,
    nc.reference,
    nc.title,
    nc.nc_type,
    nc.severity,
    nc.source,
    nc.product_id,
    nc.supplier_id,
    nc.status,
    nc.detected_by,
    nc.detected_at,
    nc.closed_at,
    nc.nb_actions,
    nc.nb_actions_open,
    nc.nb_actions_closed,
    nc.resolution_days,
    toYear(nc.detected_at)                                          as detection_year,
    toMonth(nc.detected_at)                                         as detection_month,
    if(nc.closed_at is not null,
       nc.resolution_days <= 30,
       null)                                                        as is_resolved_on_time,
    if(nc.severity in ('critical', 'major'), 1, 0)                 as is_high_severity,
    multiIf(
        nc.status = 'closed' and nc.nb_actions_open = 0,           'closed',
        nc.status = 'closed' and nc.nb_actions_open > 0,           'closed_pending_capa',
        nc.nb_actions_open > 0,                                     'in_progress',
        nc.nb_actions = 0,                                          'open_no_capa',
        'open'
    )                                                               as nc_health_status
from {{ ref('fct_qms_non_conformities') }} as nc
