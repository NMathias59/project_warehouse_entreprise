{{ config(materialized='ephemeral', tags=['intermediate', 'marketing']) }}

with email_sends as (
    select * from {{ ref('stg_marketing__email_sends') }}
),

email_events as (
    select * from {{ ref('stg_marketing__email_events') }}
)

select
    es.campaign_id,
    count(distinct es.id_email_send)                                                                as nb_sent,
    countIf(ee.event_type = 'delivered')                                                            as nb_delivered,
    countIf(ee.event_type = 'opened')                                                               as nb_opened,
    countIf(ee.event_type = 'clicked')                                                              as nb_clicked,
    countIf(ee.event_type = 'bounced')                                                              as nb_bounced,
    countIf(ee.event_type = 'unsubscribed')                                                         as nb_unsubscribed,
    countIf(ee.event_type = 'delivered') / nullIf(count(distinct es.id_email_send), 0)              as delivery_rate,
    countIf(ee.event_type = 'opened') / nullIf(count(distinct es.id_email_send), 0)                 as open_rate,
    countIf(ee.event_type = 'clicked') / nullIf(countIf(ee.event_type = 'opened'), 0)               as click_to_open_rate,
    countIf(ee.event_type = 'bounced') / nullIf(count(distinct es.id_email_send), 0)                as bounce_rate,
    countIf(ee.event_type = 'unsubscribed') / nullIf(count(distinct es.id_email_send), 0)           as unsubscribe_rate
from email_sends as es
left join email_events as ee
    on ee.email_send_id = es.id_email_send
group by
    es.campaign_id
