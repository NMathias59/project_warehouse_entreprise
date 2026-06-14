{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(id_campaign)',
    tags=['marts', 'marketing', 'dim']
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
        ended_at
    from {{ ref('stg_marketing__campaigns') }}
),

performance as (
    select
        id_campaign,
        nb_emails_sent,
        nb_opens,
        nb_clicks,
        nb_bounces,
        open_rate,
        click_rate,
        total_impressions,
        total_conversions,
        total_ad_cost,
        roi
    from {{ ref('int_marketing__campaigns_with_performance') }}
)

select
    c.id_campaign,
    c.name,
    c.campaign_type,
    c.status,
    c.channel,
    c.budget,
    c.spent,
    c.started_at,
    c.ended_at,
    p.nb_emails_sent,
    p.nb_opens,
    p.nb_clicks,
    p.nb_bounces,
    p.open_rate,
    p.click_rate,
    p.total_impressions,
    p.total_conversions,
    p.total_ad_cost,
    p.roi
from campaigns as c
left join performance as p on p.id_campaign = c.id_campaign
