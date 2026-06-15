{{ config(tags=['staging', 'sirh']) }}

with base as (

    select * from {{ ref('base_sirh__absences') }}

)

select
    cast(id                                   as varchar)       as id_absence,
    cast(coalesce(employee_id, '')            as varchar)       as employee_id,
    cast(coalesce(absence_type_id, '')        as varchar)       as absence_type_id,
    cast(coalesce(status, '')                 as varchar)       as status,
    cast(start_date                           as date)          as start_date,
    cast(end_date                             as date)          as end_date,
    cast(coalesce(duration_days, 0)           as decimal(18,2)) as duration_days,
    cast(coalesce(reason, '')                 as varchar)       as reason,
    cast(coalesce(approved_by, '')            as varchar)       as approved_by,
    toDateTimeOrNull(toString(approved_at))                     as approved_at,
    cast(created_at                           as timestamp)     as created_at,
    cast(null as Nullable(DateTime64(3)))                       as updated_at,
    cast(latest_extracted_at                as timestamp)     as _etl_loaded_at
from base
