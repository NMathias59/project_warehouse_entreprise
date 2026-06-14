{{ config(tags=['staging', 'marketing']) }}

with source as (

    select * from {{ source('marketing', 'ad_performance') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(campaign_id,          _airbyte_extracted_at) as campaign_id,
        argMax(platform,             _airbyte_extracted_at) as platform,
        argMax(ad_group,             _airbyte_extracted_at) as ad_group,
        argMax(ad_name,              _airbyte_extracted_at) as ad_name,
        argMax(date,                 _airbyte_extracted_at) as date,
        argMax(impressions,          _airbyte_extracted_at) as impressions,
        argMax(clicks,               _airbyte_extracted_at) as clicks,
        argMax(conversions,          _airbyte_extracted_at) as conversions,
        argMax(cost,                 _airbyte_extracted_at) as cost,
        argMax(revenue_attributed,   _airbyte_extracted_at) as revenue_attributed,
        argMax(created_at,           _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                          as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                    as varchar)       as id_ad_performance,
    cast(coalesce(campaign_id, '')             as varchar)       as campaign_id,
    cast(coalesce(platform, '')                as varchar)       as platform,
    cast(coalesce(ad_group, '')                as varchar)       as ad_group,
    cast(coalesce(ad_name, '')                 as varchar)       as ad_name,
    cast(date                                  as date)          as date,
    coalesce(impressions, 0)                                     as impressions,
    coalesce(clicks, 0)                                          as clicks,
    coalesce(conversions, 0)                                     as conversions,
    cast(coalesce(cost, 0)                     as decimal(18,2)) as cost,
    cast(coalesce(revenue_attributed, 0)       as decimal(18,2)) as revenue_attributed,
    cast(created_at                            as timestamp)     as created_at,
    cast(latest_extracted_at                   as timestamp)     as _etl_loaded_at
from deduped
