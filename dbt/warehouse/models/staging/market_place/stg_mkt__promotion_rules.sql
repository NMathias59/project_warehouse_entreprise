with source as (
    select * from {{ source('marketplace', 'promotion_rules') }}
),

renamed as (
    select
        _airbyte_raw_id as promotion_rule__airbyte_raw_id,
        _airbyte_extracted_at as promotion_rule__airbyte_extracted_at,
        _airbyte_meta as promotion_rule__airbyte_meta,
        _airbyte_generation_id as promotion_rule__airbyte_generation_id,
        id as promotion_rule_id,
        rule_type as promotion_rule_rule_type,
        created_at as promotion_rule_created_at,
        _ab_cdc_lsn as promotion_rule__ab_cdc_lsn,
        promotion_id as promotion_rule_promotion_id,
        applies_to_brand as promotion_rule_applies_to_brand,
        min_order_amount as promotion_rule_min_order_amount,
        _ab_cdc_deleted_at as promotion_rule__ab_cdc_deleted_at,
        _ab_cdc_updated_at as promotion_rule__ab_cdc_updated_at,
        applies_to_category as promotion_rule_applies_to_category
    from source
)

select
    promotion_rule__airbyte_raw_id,
    promotion_rule__airbyte_extracted_at,
    promotion_rule__airbyte_meta,
    promotion_rule__airbyte_generation_id,
    promotion_rule_id,
    promotion_rule_rule_type,
    promotion_rule_created_at,
    promotion_rule__ab_cdc_lsn,
    promotion_rule_promotion_id,
    promotion_rule_applies_to_brand,
    promotion_rule_min_order_amount,
    promotion_rule__ab_cdc_deleted_at,
    promotion_rule__ab_cdc_updated_at,
    promotion_rule_applies_to_category
from renamed
