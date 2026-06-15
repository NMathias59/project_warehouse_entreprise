with source as (
    select * from {{ source('marketplace', 'support_messages') }}
),

renamed as (
    select
        _airbyte_raw_id as support_message__airbyte_raw_id,
        _airbyte_extracted_at as support_message__airbyte_extracted_at,
        _airbyte_meta as support_message__airbyte_meta,
        _airbyte_generation_id as support_message__airbyte_generation_id,
        id as support_message_id,
        body as support_message_body,
        sender as support_message_sender,
        sent_at as support_message_sent_at,
        ticket_id as support_message_ticket_id,
        _ab_cdc_lsn as support_message__ab_cdc_lsn,
        _ab_cdc_deleted_at as support_message__ab_cdc_deleted_at,
        _ab_cdc_updated_at as support_message__ab_cdc_updated_at
    from source
)

select
    support_message__airbyte_raw_id,
    support_message__airbyte_extracted_at,
    support_message__airbyte_meta,
    support_message__airbyte_generation_id,
    support_message_id,
    support_message_body,
    support_message_sender,
    support_message_sent_at,
    support_message_ticket_id,
    support_message__ab_cdc_lsn,
    support_message__ab_cdc_deleted_at,
    support_message__ab_cdc_updated_at
from renamed
