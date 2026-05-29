{{ config(tags=['staging', 'erp']) }}

with source as (
    select * from {{ source('erp', 'leave_types') }}
)

select
    cast(id as varchar)                as id_leave_type,
    cast(code as varchar)              as code,
    cast(label as varchar)             as label,
    cast(is_paid as boolean)           as is_paid,
    cast(requires_approval as boolean) as requires_approval,
    cast(created_at as timestamp)      as created_at,
    cast(_ab_cdc_updated_at as varchar) as updated_at
from source
where id is not null
