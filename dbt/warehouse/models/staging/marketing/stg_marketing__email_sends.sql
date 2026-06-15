{{ config(tags=['staging', 'marketing']) }}

with base as (

    select * from {{ ref('base_marketing__email_sends') }}

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
    cast(latest_extracted_at                as timestamp) as _etl_loaded_at
from base
