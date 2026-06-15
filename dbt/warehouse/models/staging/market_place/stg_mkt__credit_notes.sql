with source as (
    select * from {{ source('marketplace', 'credit_notes') }}
),

renamed as (
    select
        _airbyte_raw_id as credit_note__airbyte_raw_id,
        _airbyte_extracted_at as credit_note__airbyte_extracted_at,
        _airbyte_meta as credit_note__airbyte_meta,
        _airbyte_generation_id as credit_note__airbyte_generation_id,
        id as credit_note_id,
        amount as credit_note_amount,
        number as credit_note_number,
        reason as credit_note_reason,
        pdf_url as credit_note_pdf_url,
        order_id as credit_note_order_id,
        issued_at as credit_note_issued_at,
        return_id as credit_note_return_id,
        _ab_cdc_lsn as credit_note__ab_cdc_lsn,
        _ab_cdc_deleted_at as credit_note__ab_cdc_deleted_at,
        _ab_cdc_updated_at as credit_note__ab_cdc_updated_at
    from source
)

select
    credit_note__airbyte_raw_id,
    credit_note__airbyte_extracted_at,
    credit_note__airbyte_meta,
    credit_note__airbyte_generation_id,
    credit_note_id,
    credit_note_amount,
    credit_note_number,
    credit_note_reason,
    credit_note_pdf_url,
    credit_note_order_id,
    credit_note_issued_at,
    credit_note_return_id,
    credit_note__ab_cdc_lsn,
    credit_note__ab_cdc_deleted_at,
    credit_note__ab_cdc_updated_at
from renamed
