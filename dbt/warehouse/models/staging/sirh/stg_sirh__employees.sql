{{ config(tags=['staging', 'sirh']) }}

with source as (

    select * from {{ source('sirh', 'employees') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(employee_number,    _airbyte_extracted_at) as employee_number,
        argMax(first_name,         _airbyte_extracted_at) as first_name,
        argMax(last_name,          _airbyte_extracted_at) as last_name,
        argMax(email,              _airbyte_extracted_at) as email,
        argMax(phone,              _airbyte_extracted_at) as phone,
        argMax(gender,             _airbyte_extracted_at) as gender,
        argMax(birth_date,         _airbyte_extracted_at) as birth_date,
        argMax(nationality,        _airbyte_extracted_at) as nationality,
        argMax(position_id,        _airbyte_extracted_at) as position_id,
        argMax(department_id,      _airbyte_extracted_at) as department_id,
        argMax(manager_id,         _airbyte_extracted_at) as manager_id,
        argMax(employment_status,  _airbyte_extracted_at) as employment_status,
        argMax(hire_date,          _airbyte_extracted_at) as hire_date,
        argMax(termination_date,   _airbyte_extracted_at) as termination_date,
        argMax(created_at,         _airbyte_extracted_at) as created_at,
        argMax(updated_at,         _airbyte_extracted_at) as updated_at,
        max(_airbyte_extracted_at)                        as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                 as varchar)   as id_employee,
    cast(coalesce(employee_number, '')      as varchar)   as employee_number,
    cast(coalesce(first_name, '')           as varchar)   as first_name,
    cast(coalesce(last_name, '')            as varchar)   as last_name,
    cast(coalesce(email, '')                as varchar)   as email,
    cast(coalesce(phone, '')                as varchar)   as phone,
    cast(coalesce(gender, '')               as varchar)   as gender,
    cast(coalesce(nationality, '')          as varchar)   as nationality,
    cast(coalesce(position_id, '')          as varchar)   as position_id,
    cast(coalesce(department_id, '')        as varchar)   as department_id,
    cast(coalesce(manager_id, '')           as varchar)   as manager_id,
    cast(coalesce(employment_status, '')    as varchar)   as employment_status,
    cast(birth_date                         as date)      as birth_date,
    cast(hire_date                          as date)      as hire_date,
    cast(termination_date                   as date)      as termination_date,
    cast(created_at                         as timestamp) as created_at,
    toDateTimeOrNull(toString(updated_at))                as updated_at,
    cast(latest_extracted_at                as timestamp) as _etl_loaded_at
from deduped
