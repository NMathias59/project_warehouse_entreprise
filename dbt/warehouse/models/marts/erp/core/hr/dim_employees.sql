{{ config(materialized='table', tags=['mart','erp','core']) }}

with employees as (

    select
        id_employee,
        first_name,
        last_name,
        email,
        hired_at,
        left_at,
        position_id,
        department_id
    from {{ ref('stg_erp__employees') }}

),

contracts_ranked as (

    select
        employee_id,
        type,
        salary,
        currency,
        starts_at,
        ends_at,
        is_active,
        row_number() over (partition by employee_id order by starts_at desc) as rn
    from {{ ref('stg_erp__employee_contracts') }}
    where is_active = true

),

contracts as (

    select
        employee_id,
        type     as contract_type,
        salary,
        currency,
        starts_at as contract_start,
        ends_at   as contract_end,
        is_active as contract_active
    from contracts_ranked
    where rn = 1

),

positions as (

    select id_position, title as position_title
    from {{ ref('stg_erp__positions') }}

),

departments as (

    select id_department, name as department_name
    from {{ ref('stg_erp__departments') }}

),

final as (

    select
        employees.id_employee,
        employees.first_name,
        employees.last_name,
        employees.email,
        employees.hired_at,
        employees.left_at,
        positions.position_title,
        departments.department_name,
        contracts.contract_type,
        contracts.salary,
        contracts.currency,
        contracts.contract_start,
        contracts.contract_end,
        contracts.contract_active
    from employees
    left join contracts   on employees.id_employee    = contracts.employee_id
    left join positions   on employees.position_id    = positions.id_position
    left join departments on employees.department_id  = departments.id_department

)

select * from final