{{ config(tags=['staging', 'marketing']) }}

with source as (

    select * from {{ source('marketing', 'email_sends') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(campaign_id,        _airbyte_extracted_at) as campaign_id,
        argMax(email_template_id,  _airbyte_extracted_at) as email_template_id,
        argMax(recipient_email,    _airbyte_extracted_at) as recipient_email,
        argMax(recipient_name,     _airbyte_extracted_at) as recipient_name,
        argMax(subject,            _airbyte_extracted_at) as subject,
        argMax(sent_at,            _airbyte_extracted_at) as sent_at,
        argMax(created_at,         _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                        as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                    as varchar)   as id_email_send,
    cast(coalesce(campaign_id, '')             as varchar)   as campaign_id,
    cast(coalesce(email_template_id, '')       as varchar)   as email_template_id,
    cast(coalesce(recipient_email, '')         as varchar)   as recipient_email,
    cast(coalesce(recipient_name, '')          as varchar)   as recipient_name,
    cast(coalesce(subject, '')                 as varchar)   as subject,
    cast(sent_at                               as timestamp) as sent_at,
    cast(created_at                            as timestamp) as created_at,
    cast(latest_extracted_at                   as timestamp) as _etl_loaded_at
from deduped
