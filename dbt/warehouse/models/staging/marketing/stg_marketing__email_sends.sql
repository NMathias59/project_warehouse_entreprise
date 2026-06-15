{{ config(tags=['staging', 'marketing']) }}

with source as (

    select * from {{ source('marketing', 'email_sends') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(campaign_id,    _airbyte_extracted_at) as campaign_id,
        argMax(email_address,  _airbyte_extracted_at) as recipient_email,
        argMax(status,         _airbyte_extracted_at) as status,
        argMax(sent_at,        _airbyte_extracted_at) as sent_at,
        max(_airbyte_extracted_at)                    as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                    as varchar)   as id_email_send,
    cast(coalesce(campaign_id, '')             as varchar)   as campaign_id,
    cast(''                                    as varchar)   as email_template_id,
    cast(coalesce(recipient_email, '')         as varchar)   as recipient_email,
    cast(''                                    as varchar)   as recipient_name,
    cast(''                                    as varchar)   as subject,
    toDateTimeOrNull(toString(sent_at))                      as sent_at,
    cast(null as Nullable(DateTime64(3)))                    as created_at,
    cast(latest_extracted_at                   as timestamp) as _etl_loaded_at
from deduped
