{{ config(materialized='ephemeral', tags=['intermediate', 'erp']) }}

select
    e.id_employee,
    e.first_name,
    e.last_name,
    e.email,
    e.hired_at,
    e.left_at,
    e.is_active,
    p.title as position_title,
    d.name as department_name,
    c.type as contract_type,
    c.salary,
    c.currency,
    c.starts_at as contract_start,
    c.ends_at as contract_end,
    c.is_active as contract_active
from {{ ref('stg_erp__employees') }} e
left join {{ ref('stg_erp__employee_contracts') }} c
  on e.id_employee = c.employee_id and c.is_active = true
left join {{ ref('stg_erp__positions') }} p
  on e.position_id = p.id_position
left join {{ ref('stg_erp__departments') }} d
  on e.department_id = d.id_department
