{{ config(materialized='view', tags=['intermediate', 'sirh']) }}

select
    e.id_employee                                            as id_employee,
    e.employee_number                                        as employee_number,
    e.first_name                                             as first_name,
    e.last_name                                              as last_name,
    e.email                                                  as email,
    e.employment_status                                      as employment_status,
    e.hire_date                                              as hire_date,
    e.termination_date                                       as termination_date,
    e.position_id                                            as position_id,
    any(pos.title)                                           as position_title,
    any(pos.job_family)                                      as position_job_family,
    e.department_id                                          as department_id,
    any(dept.name)                                           as department_name,
    e.manager_id                                             as manager_id,
    argMax(c.contract_type, c.start_date)                    as contract_type,
    argMax(c.gross_salary, c.start_date)                     as gross_salary,
    argMax(c.working_hours_per_week, c.start_date)           as working_hours_per_week,
    argMax(c.start_date, c.start_date)                       as contract_start_date,
    count(c.id_contract)                                     as nb_contracts
from {{ ref('stg_sirh__employees') }} as e
left join {{ ref('stg_sirh__contracts') }} as c
    on c.employee_id = e.id_employee
left join {{ ref('stg_sirh__positions') }} as pos
    on pos.id_position = e.position_id
left join {{ ref('stg_sirh__departments') }} as dept
    on dept.id_department = e.department_id
group by
    id_employee,
    employee_number,
    first_name,
    last_name,
    email,
    employment_status,
    hire_date,
    termination_date,
    position_id,
    department_id,
    manager_id
