{{ config(tags=['staging', 'marketing']) }}

select
    cast('' as varchar)              as id_utm_link,
    cast('' as varchar)              as campaign_id,
    cast('' as varchar)              as short_url,
    cast('' as varchar)              as full_url,
    cast('' as varchar)              as utm_source,
    cast('' as varchar)              as utm_medium,
    cast('' as varchar)              as utm_campaign,
    cast('' as varchar)              as utm_content,
    cast('' as varchar)              as utm_term,
    0                                as clicks_count,
    cast(null as Nullable(DateTime64(3))) as created_at,
    cast(null as Nullable(DateTime64(3))) as updated_at,
    cast(now() as timestamp)         as _etl_loaded_at
from {{ source('marketing', 'utm_links') }}
where 1 = 0
