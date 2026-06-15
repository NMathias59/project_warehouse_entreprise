{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(started_at)',
    settings={'allow_nullable_key': 1},
    tags=['reports', 'marketing', 'performance']
) }}

select
    c.id_campaign                                                               as id_campaign,
    c.name                                                                      as name,
    c.campaign_type                                                             as campaign_type,
    c.status                                                                    as status,
    c.channel                                                                   as channel,
    c.budget                                                                    as budget,
    c.spent                                                                     as spent,
    c.started_at                                                                as started_at,
    coalesce(ef.nb_sent, c.nb_emails_sent)                                      as nb_emails_sent,
    coalesce(ef.open_rate, c.open_rate)                                         as open_rate,
    coalesce(ef.click_to_open_rate, c.click_rate)                               as click_rate,
    coalesce(ad.total_impressions_ad, c.total_impressions)                      as total_impressions,
    coalesce(ad.total_conversions_ad, c.total_conversions)                      as total_conversions,
    coalesce(ad.total_ad_cost_agg, c.total_ad_cost)                             as total_ad_cost,
    c.roi                                                                       as roi
from {{ ref('dim_marketing_campaigns') }} as c
left join {{ ref('fct_marketing_email_funnel') }} as ef
    on ef.campaign_id = c.id_campaign
left join (
    select
        campaign_id,
        sum(impressions)    as total_impressions_ad,
        sum(conversions)    as total_conversions_ad,
        sum(cost)           as total_ad_cost_agg
    from {{ ref('fct_marketing_ad_performance') }}
    group by campaign_id
) as ad on ad.campaign_id = c.id_campaign
