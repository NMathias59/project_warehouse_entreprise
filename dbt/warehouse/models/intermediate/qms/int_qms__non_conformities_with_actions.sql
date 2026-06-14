{{ config(materialized='ephemeral', tags=['intermediate', 'qms']) }}

with non_conformities as (
    select * from {{ ref('stg_qms__non_conformities') }}
),

corrective_actions as (
    select * from {{ ref('stg_qms__corrective_actions') }}
)

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
    count(ca.id_corrective_action)                                          as nb_actions,
    countIf(ca.status in ('open', 'in_progress'))                           as nb_actions_open,
    countIf(ca.status = 'closed')                                           as nb_actions_closed,
    dateDiff('day', nc.detected_at, nc.closed_at)                          as resolution_days
from non_conformities as nc
left join corrective_actions as ca
    on ca.non_conformity_id = nc.id_non_conformity
group by
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
    nc.closed_at
