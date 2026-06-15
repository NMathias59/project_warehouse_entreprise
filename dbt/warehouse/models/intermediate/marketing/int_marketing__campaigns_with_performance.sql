{{ config(materialized='view', tags=['intermediate', 'marketing']) }}

select
    c.id_campaign                                                                   as id_campaign,
    c.name                                                                          as name,
    c.campaign_type                                                                 as campaign_type,
    c.status                                                                        as status,
    c.channel                                                                       as channel,
    c.budget                                                                        as budget,
    c.spent                                                                         as spent,
    c.started_at                                                                    as started_at,
    c.ended_at                                                                      as ended_at,
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
from {{ ref('stg_marketing__campaigns') }} as c
left join {{ ref('stg_marketing__email_sends') }} as es
    on es.campaign_id = c.id_campaign
left join {{ ref('stg_marketing__email_events') }} as ee
    on ee.send_id = es.id_email_send
left join {{ ref('stg_marketing__ad_performance') }} as ap
    on ap.campaign_id = c.id_campaign
group by
    id_campaign,
    name,
    campaign_type,
    status,
    channel,
    budget,
    spent,
    started_at,
    ended_at
