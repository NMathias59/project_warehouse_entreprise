{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(id_work_center)',
    tags=['marts', 'mes', 'dim']
) }}

with work_centers as (
    select
        id_work_center,
        code,
        name,
        work_center_type,
        capacity_per_hour,
        is_active,
        created_at
    from {{ ref('stg_mes__work_centers') }}
),

utilization as (
    select
        id_work_center,
        total_production_minutes,
        total_setup_minutes,
        total_downtime_minutes,
        utilization_rate
    from {{ ref('int_mes__work_center_utilization') }}
)

select
    wc.id_work_center,
    wc.code,
    wc.name,
    wc.work_center_type,
    wc.capacity_per_hour,
    wc.is_active,
    wc.created_at,
    u.total_production_minutes,
    u.total_setup_minutes,
    u.total_downtime_minutes,
    u.utilization_rate
from work_centers as wc
left join utilization as u on u.id_work_center = wc.id_work_center
