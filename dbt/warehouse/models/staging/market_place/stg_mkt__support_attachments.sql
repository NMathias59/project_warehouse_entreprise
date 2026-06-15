with source as (
    select * from {{ source('marketplace', 'support_attachments') }}
),

renamed as (
    select
        _airbyte_raw_id as support_attachment__airbyte_raw_id,
        _airbyte_extracted_at as support_attachment__airbyte_extracted_at,
        _airbyte_meta as support_attachment__airbyte_meta,
        _airbyte_generation_id as support_attachment__airbyte_generation_id,
        id as support_attachment_id,
        file_url as support_attachment_file_url,
        file_name as support_attachment_file_name,
        file_size as support_attachment_file_size,
        file_type as support_attachment_file_type,
        message_id as support_attachment_message_id,
        _ab_cdc_lsn as support_attachment__ab_cdc_lsn,
        uploaded_at as support_attachment_uploaded_at,
        _ab_cdc_deleted_at as support_attachment__ab_cdc_deleted_at,
        _ab_cdc_updated_at as support_attachment__ab_cdc_updated_at
    from source
)

select
    support_attachment__airbyte_raw_id,
    support_attachment__airbyte_extracted_at,
    support_attachment__airbyte_meta,
    support_attachment__airbyte_generation_id,
    support_attachment_id,
    support_attachment_file_url,
    support_attachment_file_name,
    support_attachment_file_size,
    support_attachment_file_type,
    support_attachment_message_id,
    support_attachment__ab_cdc_lsn,
    support_attachment_uploaded_at,
    support_attachment__ab_cdc_deleted_at,
    support_attachment__ab_cdc_updated_at
from renamed
