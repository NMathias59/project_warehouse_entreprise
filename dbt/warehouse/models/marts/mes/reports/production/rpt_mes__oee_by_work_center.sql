{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(id_work_center)',
    tags=['reports', 'mes', 'production']
) }}

with work_centers as (
    select
        id_work_center,
        code,
        name,
        work_center_type,
        capacity_per_hour,
        utilization_rate
    from {{ ref('dim_mes_work_centers') }}
),

time_records as (
    select
        work_center_id,
        production_minutes,
        setup_minutes,
        downtime_minutes
    from {{ ref('fct_mes_time_records') }}
),

time_agg as (
    select
        work_center_id,
        sum(production_minutes) as total_production_minutes,
        sum(setup_minutes)      as total_setup_minutes,
        sum(downtime_minutes)   as total_downtime_minutes,
        count()                 as nb_records
    from time_records
    group by work_center_id
),

final as (
    select
        wc.id_work_center,
        wc.code,
        wc.name,
        wc.work_center_type,
        wc.capacity_per_hour,
        wc.utilization_rate,
        ta.total_production_minutes,
        ta.total_setup_minutes,
        ta.total_downtime_minutes,
        ta.nb_records
    from work_centers as wc
    left join time_agg as ta on ta.work_center_id = wc.id_work_center
)

select * from final
