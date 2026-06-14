{{ config(materialized='ephemeral', tags=['intermediate', 'qms']) }}

with audits as (
    select * from {{ ref('stg_qms__audits') }}
),

audit_findings as (
    select * from {{ ref('stg_qms__audit_findings') }}
)

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
    count(af.id_audit_finding)                                      as nb_findings,
    countIf(af.finding_type = 'conformity')                         as nb_conformities,
    countIf(af.finding_type = 'minor_nc')                           as nb_minor_nc,
    countIf(af.finding_type = 'major_nc')                           as nb_major_nc,
    countIf(af.finding_type = 'observation')                        as nb_observations,
    countIf(af.is_critical)                                         as nb_critical,
    countIf(af.corrective_action_id != '')                          as nb_with_capa
from audits as a
left join audit_findings as af
    on af.audit_id = a.id_audit
group by
    a.id_audit,
    a.reference,
    a.audit_type,
    a.scope,
    a.auditor_id,
    a.auditee_department,
    a.planned_at,
    a.completed_at,
    a.status,
    a.overall_result
