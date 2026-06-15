with source as (
    select * from {{ source('marketplace', 'loyalty_transactions') }}
),

renamed as (
    select
        _airbyte_raw_id as loyalty_transaction__airbyte_raw_id,
        _airbyte_extracted_at as loyalty_transaction__airbyte_extracted_at,
        _airbyte_meta as loyalty_transaction__airbyte_meta,
        _airbyte_generation_id as loyalty_transaction__airbyte_generation_id,
        id as loyalty_transaction_id,
        type as loyalty_transaction_type,
        points as loyalty_transaction_points,
        reference as loyalty_transaction_reference,
        created_at as loyalty_transaction_created_at,
        _ab_cdc_lsn as loyalty_transaction__ab_cdc_lsn,
        customer_id as loyalty_transaction_customer_id,
        _ab_cdc_deleted_at as loyalty_transaction__ab_cdc_deleted_at,
        _ab_cdc_updated_at as loyalty_transaction__ab_cdc_updated_at
    from source
)

select
    loyalty_transaction__airbyte_raw_id,
    loyalty_transaction__airbyte_extracted_at,
    loyalty_transaction__airbyte_meta,
    loyalty_transaction__airbyte_generation_id,
    loyalty_transaction_id,
    loyalty_transaction_type,
    loyalty_transaction_points,
    loyalty_transaction_reference,
    loyalty_transaction_created_at,
    loyalty_transaction__ab_cdc_lsn,
    loyalty_transaction_customer_id,
    loyalty_transaction__ab_cdc_deleted_at,
    loyalty_transaction__ab_cdc_updated_at
from renamed
