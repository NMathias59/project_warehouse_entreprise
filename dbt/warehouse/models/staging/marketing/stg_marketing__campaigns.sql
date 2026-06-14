{{ config(tags=['staging', 'marketing']) }}

with source as (

    select * from {{ source('marketing', 'campaigns') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(name,             _airbyte_extracted_at) as name,
        argMax(campaign_type,    _airbyte_extracted_at) as campaign_type,
        argMax(status,           _airbyte_extracted_at) as status,
        argMax(channel,          _airbyte_extracted_at) as channel,
        argMax(budget,           _airbyte_extracted_at) as budget,
        argMax(spent,            _airbyte_extracted_at) as spent,
        argMax(target_audience,  _airbyte_extracted_at) as target_audience,
        argMax(started_at,       _airbyte_extracted_at) as started_at,
        argMax(ended_at,         _airbyte_extracted_at) as ended_at,
        argMax(created_by,       _airbyte_extracted_at) as created_by,
        argMax(created_at,       _airbyte_extracted_at) as created_at,
        argMax(updated_at,       _airbyte_extracted_at) as updated_at,
        max(_airbyte_extracted_at)                      as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                  as varchar)       as id_campaign,
    cast(coalesce(name, '')                  as varchar)       as name,
    cast(coalesce(campaign_type, '')         as varchar)       as campaign_type,
    cast(coalesce(status, '')                as varchar)       as status,
    cast(coalesce(channel, '')               as varchar)       as channel,
    cast(coalesce(budget, 0)                 as decimal(18,2)) as budget,
    cast(coalesce(spent, 0)                  as decimal(18,2)) as spent,
    cast(coalesce(target_audience, '')       as varchar)       as target_audience,
    toDateTimeOrNull(toString(started_at))                     as started_at,
    toDateTimeOrNull(toString(ended_at))                       as ended_at,
    cast(coalesce(created_by, '')            as varchar)       as created_by,
    cast(created_at                          as timestamp)     as created_at,
    toDateTimeOrNull(toString(updated_at))                     as updated_at,
    cast(latest_extracted_at                 as timestamp)     as _etl_loaded_at
from deduped
