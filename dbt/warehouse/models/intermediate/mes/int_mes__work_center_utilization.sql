{{ config(materialized='ephemeral', tags=['intermediate', 'mes']) }}

with work_centers as (
    select * from {{ ref('stg_mes__work_centers') }}
),

time_records as (
    select * from {{ ref('stg_mes__time_records') }}
)

select
    wc.id_work_center,
    wc.code,
    wc.name,
    wc.work_center_type,
    wc.capacity_per_hour,
    wc.is_active,
    count(tr.id_time_record)                                                                                    as nb_time_records,
    sumIf(tr.duration_minutes, tr.record_type = 'production')                                                   as total_production_minutes,
    sumIf(tr.duration_minutes, tr.record_type = 'setup')                                                        as total_setup_minutes,
    sumIf(tr.duration_minutes, tr.record_type = 'downtime')                                                     as total_downtime_minutes,
    sumIf(tr.duration_minutes, tr.record_type = 'production')
        / nullIf(
            sumIf(tr.duration_minutes, tr.record_type = 'production')
            + sumIf(tr.duration_minutes, tr.record_type = 'downtime'),
            0
          )                                                                                                     as utilization_rate
from work_centers as wc
left join time_records as tr
    on tr.work_center_id = wc.id_work_center
group by
    wc.id_work_center,
    wc.code,
    wc.name,
    wc.work_center_type,
    wc.capacity_per_hour,
    wc.is_active
