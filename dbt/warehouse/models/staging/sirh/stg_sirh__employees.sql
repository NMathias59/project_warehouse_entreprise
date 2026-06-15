{{ config(tags=['staging', 'sirh']) }}

with base as (

    select * from {{ ref('base_sirh__employees') }}

)

select
    cast(id                                 as varchar)   as id_employee,
    cast(coalesce(employee_number, '')      as varchar)   as employee_number,
    cast(coalesce(first_name, '')           as varchar)   as first_name,
    cast(coalesce(last_name, '')            as varchar)   as last_name,
    cast(coalesce(email, '')                as varchar)   as email,
    cast(coalesce(phone, '')                as varchar)   as phone,
    cast(''                                 as varchar)   as gender,
    cast(coalesce(nationality, '')          as varchar)   as nationality,
    cast(coalesce(position_id, '')          as varchar)   as position_id,
    cast(coalesce(department_id, '')        as varchar)   as department_id,
    cast(coalesce(manager_id, '')           as varchar)   as manager_id,
    cast(coalesce(employment_status, '')    as varchar)   as employment_status,
    cast(birth_date                         as date)      as birth_date,
    cast(hire_date                          as date)      as hire_date,
    cast(null as Nullable(Date32))                        as termination_date,
    cast(created_at                         as timestamp) as created_at,
    cast(null as Nullable(DateTime64(3)))                 as updated_at,
    cast(latest_extracted_at                as timestamp) as _etl_loaded_at
from base
