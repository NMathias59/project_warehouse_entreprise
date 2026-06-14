{{ config(tags=['staging', 'marketing']) }}

with source as (

    select * from {{ source('marketing', 'leads') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(first_name,    _airbyte_extracted_at) as first_name,
        argMax(last_name,     _airbyte_extracted_at) as last_name,
        argMax(email,         _airbyte_extracted_at) as email,
        argMax(phone,         _airbyte_extracted_at) as phone,
        argMax(company,       _airbyte_extracted_at) as company,
        argMax(job_title,     _airbyte_extracted_at) as job_title,
        argMax(lead_source,   _airbyte_extracted_at) as lead_source,
        argMax(campaign_id,   _airbyte_extracted_at) as campaign_id,
        argMax(status,        _airbyte_extracted_at) as status,
        argMax(score,         _airbyte_extracted_at) as score,
        argMax(converted_at,  _airbyte_extracted_at) as converted_at,
        argMax(assigned_to,   _airbyte_extracted_at) as assigned_to,
        argMax(created_at,    _airbyte_extracted_at) as created_at,
        argMax(updated_at,    _airbyte_extracted_at) as updated_at,
        max(_airbyte_extracted_at)                   as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                as varchar)   as id_lead,
    cast(coalesce(first_name, '')          as varchar)   as first_name,
    cast(coalesce(last_name, '')           as varchar)   as last_name,
    cast(coalesce(email, '')               as varchar)   as email,
    cast(coalesce(phone, '')               as varchar)   as phone,
    cast(coalesce(company, '')             as varchar)   as company,
    cast(coalesce(job_title, '')           as varchar)   as job_title,
    cast(coalesce(lead_source, '')         as varchar)   as lead_source,
    cast(coalesce(campaign_id, '')         as varchar)   as campaign_id,
    cast(coalesce(status, '')              as varchar)   as status,
    coalesce(score, 0)                                   as score,
    toDateTimeOrNull(toString(converted_at))             as converted_at,
    cast(coalesce(assigned_to, '')         as varchar)   as assigned_to,
    cast(created_at                        as timestamp) as created_at,
    toDateTimeOrNull(toString(updated_at))               as updated_at,
    cast(latest_extracted_at               as timestamp) as _etl_loaded_at
from deduped
