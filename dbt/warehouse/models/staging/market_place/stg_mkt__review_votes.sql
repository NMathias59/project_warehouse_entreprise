with source as (
    select * from {{ source('marketplace', 'review_votes') }}
),

renamed as (
    select
        _airbyte_raw_id as review_vote__airbyte_raw_id,
        _airbyte_extracted_at as review_vote__airbyte_extracted_at,
        _airbyte_meta as review_vote__airbyte_meta,
        _airbyte_generation_id as review_vote__airbyte_generation_id,
        id as review_vote_id,
        vote as review_vote_vote,
        review_id as review_vote_review_id,
        created_at as review_vote_created_at,
        _ab_cdc_lsn as review_vote__ab_cdc_lsn,
        customer_id as review_vote_customer_id,
        _ab_cdc_deleted_at as review_vote__ab_cdc_deleted_at,
        _ab_cdc_updated_at as review_vote__ab_cdc_updated_at
    from source
)

select
    review_vote__airbyte_raw_id,
    review_vote__airbyte_extracted_at,
    review_vote__airbyte_meta,
    review_vote__airbyte_generation_id,
    review_vote_id,
    review_vote_vote,
    review_vote_review_id,
    review_vote_created_at,
    review_vote__ab_cdc_lsn,
    review_vote_customer_id,
    review_vote__ab_cdc_deleted_at,
    review_vote__ab_cdc_updated_at
from renamed
