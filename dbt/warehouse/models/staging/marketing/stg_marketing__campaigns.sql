{{ config(tags=['staging', 'marketing']) }}

with base as (

    select * from {{ ref('base_marketing__campaigns') }}

)

select
    cast(id                                  as varchar)       as id_campaign,
    cast(coalesce(name, '')                  as varchar)       as name,
    cast(coalesce(campaign_type, '')         as varchar)       as campaign_type,
    cast(coalesce(status, '')                as varchar)       as status,
    cast(coalesce(channel, '')               as varchar)       as channel,
    cast(0                                   as decimal(18,2)) as budget,
    cast(0                                   as decimal(18,2)) as spent,
    cast(coalesce(target_audience, '')       as varchar)       as target_audience,
    toDateTimeOrNull(toString(started_at))                     as started_at,
    toDateTimeOrNull(toString(ended_at))                       as ended_at,
    cast(''                                  as varchar)       as created_by,
    cast(created_at                          as timestamp)     as created_at,
    toDateTimeOrNull(toString(updated_at))                     as updated_at,
    cast(latest_extracted_at                as timestamp)     as _etl_loaded_at
from base
