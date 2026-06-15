{{ config(tags=['staging', 'marketing']) }}

select
    cast('' as varchar)              as id_lead,
    cast('' as varchar)              as first_name,
    cast('' as varchar)              as last_name,
    cast('' as varchar)              as email,
    cast('' as varchar)              as phone,
    cast('' as varchar)              as company,
    cast('' as varchar)              as job_title,
    cast('' as varchar)              as lead_source,
    cast('' as varchar)              as campaign_id,
    cast('' as varchar)              as status,
    0                                as score,
    cast(null as Nullable(DateTime64(3))) as converted_at,
    cast('' as varchar)              as assigned_to,
    cast(null as Nullable(DateTime64(3))) as created_at,
    cast(null as Nullable(DateTime64(3))) as updated_at,
    cast(now() as timestamp)         as _etl_loaded_at
from {{ source('marketing', 'leads') }}
where 1 = 0
