with source as (
    select * from {{ source('marketplace', 'price_history') }}
),

renamed as (
    select
        _airbyte_raw_id as price_history__airbyte_raw_id,
        _airbyte_extracted_at as price_history__airbyte_extracted_at,
        _airbyte_meta as price_history__airbyte_meta,
        _airbyte_generation_id as price_history__airbyte_generation_id,
        id as price_history_id,
        price_ht as price_history_price_ht,
        price_ttc as price_history_price_ttc,
        changed_at as price_history_changed_at,
        changed_by as price_history_changed_by,
        product_id as price_history_product_id,
        _ab_cdc_lsn as price_history__ab_cdc_lsn,
        _ab_cdc_deleted_at as price_history__ab_cdc_deleted_at,
        _ab_cdc_updated_at as price_history__ab_cdc_updated_at
    from source
)

select * from renamed
