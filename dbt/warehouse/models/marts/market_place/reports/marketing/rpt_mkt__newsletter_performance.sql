{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='tuple()',
    tags=['reports', 'market_place', 'marketing']
) }}

with subscribers as (

    select
        count(*)                                                as total_subscribers,
        countIf(newsletter_subscription_is_active = true)      as active_subscribers,
        countIf(newsletter_subscription_is_active = false)     as unsubscribed_count
    from {{ ref('stg_mkt__newsletter_subscriptions') }}

),

campaigns as (

    select
        newsletter_campaign_id,
        newsletter_campaign_subject,
        toDate(newsletter_campaign_sent_at)                     as sent_date,
        newsletter_campaign_sent_to_count,
        newsletter_campaign_opened_count,
        newsletter_campaign_clicked_count
    from {{ ref('stg_mkt__newsletter_campaigns') }}
    where newsletter_campaign__ab_cdc_deleted_at is null

)

select
    c.newsletter_campaign_id                                    as campaign_id,
    c.newsletter_campaign_subject                               as subject,
    c.sent_date,
    c.newsletter_campaign_sent_to_count                        as sent_to_count,
    c.newsletter_campaign_opened_count                         as opened_count,
    c.newsletter_campaign_clicked_count                        as clicked_count,
    s.total_subscribers,
    s.active_subscribers,
    s.unsubscribed_count,
    if(c.newsletter_campaign_sent_to_count > 0,
       round(c.newsletter_campaign_opened_count * 100.0
             / c.newsletter_campaign_sent_to_count, 2),
       0)                                                       as open_rate_pct,
    if(c.newsletter_campaign_sent_to_count > 0,
       round(c.newsletter_campaign_clicked_count * 100.0
             / c.newsletter_campaign_sent_to_count, 2),
       0)                                                       as click_rate_pct,
    if(c.newsletter_campaign_opened_count > 0,
       round(c.newsletter_campaign_clicked_count * 100.0
             / c.newsletter_campaign_opened_count, 2),
       0)                                                       as click_to_open_rate_pct
from campaigns as c
cross join subscribers as s
