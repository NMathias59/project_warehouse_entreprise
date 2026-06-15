{{ config(tags=['staging', 'marketing']) }}

select
    cast('' as varchar)              as id_ad_performance,
    cast('' as varchar)              as campaign_id,
    cast('' as varchar)              as platform,
    cast('' as varchar)              as ad_group,
    cast('' as varchar)              as ad_name,
    cast(null as Nullable(Date32))   as date,
    0                                as impressions,
    0                                as clicks,
    0                                as conversions,
    cast(0 as decimal(18,2))         as cost,
    cast(0 as decimal(18,2))         as revenue_attributed,
    cast(null as Nullable(DateTime64(3))) as created_at,
    cast(now() as timestamp)         as _etl_loaded_at
from {{ source('marketing', 'ad_performance') }}
where 1 = 0
