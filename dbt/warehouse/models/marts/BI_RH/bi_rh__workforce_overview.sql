{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(department_name, id_employee)',
    tags=['bi', 'rh']
) }}

select
    e.id_employee,
    e.first_name,
    e.last_name,
    e.email,
    e.department_name,
    e.position_title,
    e.contract_type,
    e.salary,
    e.currency,
    e.hired_at,
    e.left_at,
    if(e.left_at is null, 1, 0)                                         as is_active,
    dateDiff('month', e.hired_at, coalesce(e.left_at, today()))         as tenure_months,
    round(dateDiff('month', e.hired_at, coalesce(e.left_at, today()))
          / 12.0, 1)                                                    as tenure_years,
    multiIf(
        e.left_at is not null,                          'departed',
        dateDiff('month', e.hired_at, today()) < 3,     'onboarding',
        dateDiff('month', e.hired_at, today()) < 12,    'junior',
        dateDiff('year',  e.hired_at, today()) < 3,     'experienced',
        'senior'
    )                                                                   as seniority_band
from {{ ref('dim_employees') }} as e
