with source as (
    select * from {{ source('marketplace', 'product_answers') }}
),

renamed as (
    select
        _airbyte_raw_id as product_answer__airbyte_raw_id,
        _airbyte_extracted_at as product_answer__airbyte_extracted_at,
        _airbyte_meta as product_answer__airbyte_meta,
        _airbyte_generation_id as product_answer__airbyte_generation_id,
        id as product_answer_id,
        body as product_answer_body,
        created_at as product_answer_created_at,
        _ab_cdc_lsn as product_answer__ab_cdc_lsn,
        answered_by as product_answer_answered_by,
        is_official as product_answer_is_official,
        question_id as product_answer_question_id,
        _ab_cdc_deleted_at as product_answer__ab_cdc_deleted_at,
        _ab_cdc_updated_at as product_answer__ab_cdc_updated_at
    from source
)

select * from renamed
