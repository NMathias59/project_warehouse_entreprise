with source as (
    select * from {{ source('marketplace', 'newsletter_campaigns') }}
),

renamed as (
    select
        _airbyte_raw_id as newsletter_campaign__airbyte_raw_id,
        _airbyte_extracted_at as newsletter_campaign__airbyte_extracted_at,
        _airbyte_meta as newsletter_campaign__airbyte_meta,
        _airbyte_generation_id as newsletter_campaign__airbyte_generation_id,
        id as newsletter_campaign_id,
        sent_at as newsletter_campaign_sent_at,
        subject as newsletter_campaign_subject,
        body_html as newsletter_campaign_body_html,
        created_at as newsletter_campaign_created_at,
        _ab_cdc_lsn as newsletter_campaign__ab_cdc_lsn,
        opened_count as newsletter_campaign_opened_count,
        clicked_count as newsletter_campaign_clicked_count,
        sent_to_count as newsletter_campaign_sent_to_count,
        _ab_cdc_deleted_at as newsletter_campaign__ab_cdc_deleted_at,
        _ab_cdc_updated_at as newsletter_campaign__ab_cdc_updated_at
    from source
)

select * from renamed
