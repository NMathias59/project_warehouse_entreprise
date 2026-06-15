with source as (
    select * from {{ source('marketplace', 'reviews') }}
),

renamed as (
    select
        _airbyte_raw_id as review__airbyte_raw_id,
        _airbyte_extracted_at as review__airbyte_extracted_at,
        _airbyte_meta as review__airbyte_meta,
        _airbyte_generation_id as review__airbyte_generation_id,
        id as review_id,
        body as review_body,
        title as review_title,
        rating as review_rating,
        created_at as review_created_at,
        deleted_at as review_deleted_at,
        product_id as review_product_id,
        _ab_cdc_lsn as review__ab_cdc_lsn,
        customer_id as review_customer_id,
        is_verified as review_is_verified,
        order_line_id as review_order_line_id,
        _ab_cdc_deleted_at as review__ab_cdc_deleted_at,
        _ab_cdc_updated_at as review__ab_cdc_updated_at
    from source
)

select
    review__airbyte_raw_id,
    review__airbyte_extracted_at,
    review__airbyte_meta,
    review__airbyte_generation_id,
    review_id,
    review_body,
    review_title,
    review_rating,
    review_created_at,
    review_deleted_at,
    review_product_id,
    review__ab_cdc_lsn,
    review_customer_id,
    review_is_verified,
    review_order_line_id,
    review__ab_cdc_deleted_at,
    review__ab_cdc_updated_at
from renamed
