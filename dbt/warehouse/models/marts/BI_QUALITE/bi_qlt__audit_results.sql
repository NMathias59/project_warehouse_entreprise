{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(id_audit, planned_at)',
    settings={'allow_nullable_key': 1},
    tags=['bi', 'qualite']
) }}

select
    a.id_audit,
    a.reference,
    a.audit_type,
    a.scope,
    a.auditor_id,
    a.auditee_department,
    a.planned_at,
    a.completed_at,
    a.status,
    a.overall_result,
    a.nb_findings,
    a.nb_conformities,
    a.nb_minor_nc,
    a.nb_major_nc,
    a.nb_observations,
    a.nb_critical,
    a.nb_with_capa,
    if(a.nb_findings > 0,
       round(a.nb_conformities * 100.0 / a.nb_findings, 1),
       null)                                                        as conformity_rate_pct,
    if(a.planned_at is not null and a.completed_at is not null,
       dateDiff('day', a.planned_at, a.completed_at),
       null)                                                        as audit_duration_days,
    if(a.completed_at is not null and a.planned_at is not null,
       a.completed_at <= a.planned_at + interval 7 day,
       null)                                                        as is_completed_on_schedule,
    toYear(a.planned_at)                                            as audit_year,
    multiIf(
        a.overall_result = 'satisfactory',                          'green',
        a.overall_result = 'minor_issues',                          'orange',
        a.overall_result = 'major_issues',                          'red',
        'unknown'
    )                                                               as risk_level
from {{ ref('fct_qms_audits') }} as a
