{{ config(materialized='ephemeral', tags=['intermediate', 'marketing']) }}

with campaigns as (
    select * from {{ ref('stg_marketing__campaigns') }}
),

email_sends as (
    select * from {{ ref('stg_marketing__email_sends') }}
),

email_events as (
    select * from {{ ref('stg_marketing__email_events') }}
),

ad_performance as (
    select * from {{ ref('stg_marketing__ad_performance') }}
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
    count(distinct es.id_email_send)                                                as nb_emails_sent,
    countIf(ee.event_type = 'opened')                                               as nb_opens,
    countIf(ee.event_type = 'clicked')                                              as nb_clicks,
    countIf(ee.event_type = 'bounced')                                              as nb_bounces,
    countIf(ee.event_type = 'unsubscribed')                                         as nb_unsubscribes,
    countIf(ee.event_type = 'opened') / nullIf(count(distinct es.id_email_send), 0) as open_rate,
    countIf(ee.event_type = 'clicked') / nullIf(count(distinct es.id_email_send), 0) as click_rate,
    sum(ap.impressions)                                                             as total_impressions,
    sum(ap.clicks)                                                                  as total_ad_clicks,
    sum(ap.conversions)                                                             as total_conversions,
    sum(ap.cost)                                                                    as total_ad_cost,
    sum(ap.revenue_attributed) / nullIf(sum(ap.cost), 0)                           as roi
from campaigns as c
left join email_sends as es
    on es.campaign_id = c.id_campaign
left join email_events as ee
    on ee.campaign_id = c.id_campaign
left join ad_performance as ap
    on ap.campaign_id = c.id_campaign
group by
    c.id_campaign,
    c.name,
    c.campaign_type,
    c.status,
    c.channel,
    c.budget,
    c.spent,
    c.started_at,
    c.ended_at
