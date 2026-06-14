{{ config(materialized='table', engine='MergeTree()', order_by='(nc_type, severity)', tags=['reports','qms','quality']) }}
with nc as (
    select nc_type, severity, status, resolution_days, nb_actions, nb_actions_open
    from {{ ref('fct_qms_non_conformities') }}
),
final as (
    select
        nc_type,
        severity,
        status,
        count(*)                                as nb_nc,
        avg(resolution_days)                    as avg_resolution_days,
        sum(nb_actions)                         as total_actions,
        sum(nb_actions_open)                    as total_open_actions,
        countIf(severity = 'critical')          as nb_critical
    from nc
    group by nc_type, severity, status
)
select * from final
