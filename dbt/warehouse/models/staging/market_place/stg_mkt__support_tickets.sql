with source as (
    select * from {{ source('marketplace', 'support_tickets') }}
),

renamed as (
    select
        _airbyte_raw_id as support_ticket__airbyte_raw_id,
        _airbyte_extracted_at as support_ticket__airbyte_extracted_at,
        _airbyte_meta as support_ticket__airbyte_meta,
        _airbyte_generation_id as support_ticket__airbyte_generation_id,
        id as support_ticket_id,
        status as support_ticket_status,
        subject as support_ticket_subject,
        order_id as support_ticket_order_id,
        priority as support_ticket_priority,
        created_at as support_ticket_created_at,
        deleted_at as support_ticket_deleted_at,
        _ab_cdc_lsn as support_ticket__ab_cdc_lsn,
        customer_id as support_ticket_customer_id,
        resolved_at as support_ticket_resolved_at,
        _ab_cdc_deleted_at as support_ticket__ab_cdc_deleted_at,
        _ab_cdc_updated_at as support_ticket__ab_cdc_updated_at
    from source
)

select * from renamed
