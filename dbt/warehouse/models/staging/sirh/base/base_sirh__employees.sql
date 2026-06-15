{{ config(materialized='view', tags=['staging', 'sirh']) }}

select
    id,
    argMax(employee_number, _airbyte_extracted_at) as employee_number,
    argMax(first_name,      _airbyte_extracted_at) as first_name,
    argMax(last_name,       _airbyte_extracted_at) as last_name,
    argMax(email,           _airbyte_extracted_at) as email,
    argMax(phone,           _airbyte_extracted_at) as phone,
    argMax(birthdate,       _airbyte_extracted_at) as birth_date,
    argMax(nationality,     _airbyte_extracted_at) as nationality,
    argMax(position_id,     _airbyte_extracted_at) as position_id,
    argMax(department_id,   _airbyte_extracted_at) as department_id,
    argMax(manager_id,      _airbyte_extracted_at) as manager_id,
    argMax(status,          _airbyte_extracted_at) as employment_status,
    argMax(hire_date,       _airbyte_extracted_at) as hire_date,
    argMax(created_at,      _airbyte_extracted_at) as created_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('sirh', 'employees') }}
where id is not null
group by id
