{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(channel)',
    tags=['reports', 'marketing', 'performance']
) }}

with ad_performance as (
    select
        campaign_id,
        impressions,
        clicks,
        conversions,
        cost,
        revenue_attributed
    from {{ ref('fct_marketing_ad_performance') }}
),

campaigns as (
    select
        id_campaign,
        channel,
        roi
    from {{ ref('dim_marketing_campaigns') }}
),

joined as (
    select
        c.channel,
        c.id_campaign,
        ap.impressions,
        ap.clicks,
        ap.conversions,
        ap.cost,
        ap.revenue_attributed,
        c.roi
    from ad_performance as ap
    left join campaigns as c on c.id_campaign = ap.campaign_id
),

final as (
    select
        channel,
        countDistinct(id_campaign)              as nb_campaigns,
        sum(impressions)                        as total_impressions,
        sum(clicks)                             as total_clicks,
        sum(conversions)                        as total_conversions,
        sum(cost)                               as total_cost,
        sum(revenue_attributed)                 as total_revenue,
        sum(cost) / nullIf(sum(clicks), 0)      as avg_cpc,
        avg(roi)                                as avg_roi
    from joined
    group by channel
)

select * from final
