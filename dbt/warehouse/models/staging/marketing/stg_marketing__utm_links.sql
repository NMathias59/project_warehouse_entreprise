{{ config(tags=['staging', 'marketing']) }}

with source as (

    select * from {{ source('marketing', 'utm_links') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(campaign_id,   _airbyte_extracted_at) as campaign_id,
        argMax(short_url,     _airbyte_extracted_at) as short_url,
        argMax(full_url,      _airbyte_extracted_at) as full_url,
        argMax(utm_source,    _airbyte_extracted_at) as utm_source,
        argMax(utm_medium,    _airbyte_extracted_at) as utm_medium,
        argMax(utm_campaign,  _airbyte_extracted_at) as utm_campaign,
        argMax(utm_content,   _airbyte_extracted_at) as utm_content,
        argMax(utm_term,      _airbyte_extracted_at) as utm_term,
        argMax(clicks_count,  _airbyte_extracted_at) as clicks_count,
        argMax(created_at,    _airbyte_extracted_at) as created_at,
        argMax(updated_at,    _airbyte_extracted_at) as updated_at,
        max(_airbyte_extracted_at)                   as latest_extracted_at
    from source
    group by id

)

select
    cast(id                              as varchar)   as id_utm_link,
    cast(coalesce(campaign_id, '')       as varchar)   as campaign_id,
    cast(coalesce(short_url, '')         as varchar)   as short_url,
    cast(coalesce(full_url, '')          as varchar)   as full_url,
    cast(coalesce(utm_source, '')        as varchar)   as utm_source,
    cast(coalesce(utm_medium, '')        as varchar)   as utm_medium,
    cast(coalesce(utm_campaign, '')      as varchar)   as utm_campaign,
    cast(coalesce(utm_content, '')       as varchar)   as utm_content,
    cast(coalesce(utm_term, '')          as varchar)   as utm_term,
    coalesce(clicks_count, 0)                          as clicks_count,
    cast(created_at                      as timestamp) as created_at,
    toDateTimeOrNull(toString(updated_at))             as updated_at,
    cast(latest_extracted_at             as timestamp) as _etl_loaded_at
from deduped
