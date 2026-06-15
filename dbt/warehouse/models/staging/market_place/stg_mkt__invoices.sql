with source as (
    select * from {{ source('marketplace', 'invoices') }}
),

renamed as (
    select
        _airbyte_raw_id as invoice__airbyte_raw_id,
        _airbyte_extracted_at as invoice__airbyte_extracted_at,
        _airbyte_meta as invoice__airbyte_meta,
        _airbyte_generation_id as invoice__airbyte_generation_id,
        id as invoice_id,
        due_at as invoice_due_at,
        number as invoice_number,
        pdf_url as invoice_pdf_url,
        order_id as invoice_order_id,
        issued_at as invoice_issued_at,
        total_ttc as invoice_total_ttc,
        _ab_cdc_lsn as invoice__ab_cdc_lsn,
        _ab_cdc_deleted_at as invoice__ab_cdc_deleted_at,
        _ab_cdc_updated_at as invoice__ab_cdc_updated_at
    from source
)

select
    invoice__airbyte_raw_id,
    invoice__airbyte_extracted_at,
    invoice__airbyte_meta,
    invoice__airbyte_generation_id,
    invoice_id,
    invoice_due_at,
    invoice_number,
    invoice_pdf_url,
    invoice_order_id,
    invoice_issued_at,
    invoice_total_ttc,
    invoice__ab_cdc_lsn,
    invoice__ab_cdc_deleted_at,
    invoice__ab_cdc_updated_at
from renamed
