with source as (
    select * from {{ source('marketplace', 'newsletter_subscriptions') }}
),

renamed as (
    select
        _airbyte_raw_id as newsletter_subscription__airbyte_raw_id,
        _airbyte_extracted_at as newsletter_subscription__airbyte_extracted_at,
        _airbyte_meta as newsletter_subscription__airbyte_meta,
        _airbyte_generation_id as newsletter_subscription__airbyte_generation_id,
        id as newsletter_subscription_id,
        email as newsletter_subscription_email,
        is_active as newsletter_subscription_is_active,
        _ab_cdc_lsn as newsletter_subscription__ab_cdc_lsn,
        subscribed_at as newsletter_subscription_subscribed_at,
        unsubscribed_at as newsletter_subscription_unsubscribed_at,
        _ab_cdc_deleted_at as newsletter_subscription__ab_cdc_deleted_at,
        _ab_cdc_updated_at as newsletter_subscription__ab_cdc_updated_at
    from source
)

select
    newsletter_subscription__airbyte_raw_id,
    newsletter_subscription__airbyte_extracted_at,
    newsletter_subscription__airbyte_meta,
    newsletter_subscription__airbyte_generation_id,
    newsletter_subscription_id,
    newsletter_subscription_email,
    newsletter_subscription_is_active,
    newsletter_subscription__ab_cdc_lsn,
    newsletter_subscription_subscribed_at,
    newsletter_subscription_unsubscribed_at,
    newsletter_subscription__ab_cdc_deleted_at,
    newsletter_subscription__ab_cdc_updated_at
from renamed
