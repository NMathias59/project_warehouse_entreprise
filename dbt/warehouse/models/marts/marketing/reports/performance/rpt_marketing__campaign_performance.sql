{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(started_at)',
    tags=['reports', 'marketing', 'performance']
) }}

with campaigns as (
    select
        id_campaign,
        name,
        campaign_type,
        status,
        channel,
        budget,
        spent,
        started_at,
        nb_emails_sent,
        open_rate,
        click_rate,
        total_impressions,
        total_conversions,
        total_ad_cost,
        roi
    from {{ ref('dim_marketing_campaigns') }}
),

email_funnel as (
    select
        campaign_id,
        nb_emails_sent  as ef_nb_emails_sent,
        open_rate       as ef_open_rate,
        click_rate      as ef_click_rate
    from {{ ref('fct_marketing_email_funnel') }}
),

ad_agg as (
    select
        campaign_id,
        sum(impressions)   as total_impressions_ad,
        sum(conversions)   as total_conversions_ad,
        sum(cost)          as total_ad_cost_agg
    from {{ ref('fct_marketing_ad_performance') }}
    group by campaign_id
),

final as (
    select
        c.id_campaign,
        c.name,
        c.campaign_type,
        c.status,
        c.channel,
        c.budget,
        c.spent,
        c.started_at,
        coalesce(ef.ef_nb_emails_sent, c.nb_emails_sent)     as nb_emails_sent,
        coalesce(ef.ef_open_rate, c.open_rate)               as open_rate,
        coalesce(ef.ef_click_rate, c.click_rate)             as click_rate,
        coalesce(ad.total_impressions_ad, c.total_impressions) as total_impressions,
        coalesce(ad.total_conversions_ad, c.total_conversions) as total_conversions,
        coalesce(ad.total_ad_cost_agg, c.total_ad_cost)      as total_ad_cost,
        c.roi
    from campaigns as c
    left join email_funnel as ef on ef.campaign_id = c.id_campaign
    left join ad_agg as ad on ad.campaign_id = c.id_campaign
)

select * from final
