with source as (
    select * from {{ source('marketplace', 'product_questions') }}
),

renamed as (
    select
        _airbyte_raw_id as product_question__airbyte_raw_id,
        _airbyte_extracted_at as product_question__airbyte_extracted_at,
        _airbyte_meta as product_question__airbyte_meta,
        _airbyte_generation_id as product_question__airbyte_generation_id,
        id as product_question_id,
        question as product_question_question,
        created_at as product_question_created_at,
        deleted_at as product_question_deleted_at,
        product_id as product_question_product_id,
        _ab_cdc_lsn as product_question__ab_cdc_lsn,
        customer_id as product_question_customer_id,
        is_answered as product_question_is_answered,
        _ab_cdc_deleted_at as product_question__ab_cdc_deleted_at,
        _ab_cdc_updated_at as product_question__ab_cdc_updated_at
    from source
)

select * from renamed
