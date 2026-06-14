{{ config(materialized='ephemeral', tags=['intermediate', 'marketing']) }}

with leads as (
    select * from {{ ref('stg_marketing__leads') }}
),

campaigns as (
    select * from {{ ref('stg_marketing__campaigns') }}
)

select
    l.id_lead,
    l.first_name,
    l.last_name,
    l.email,
    l.company,
    l.job_title,
    l.lead_source,
    l.status,
    l.score,
    l.campaign_id,
    c.name                                                          as campaign_name,
    c.campaign_type,
    c.channel,
    l.converted_at,
    l.assigned_to,
    l.created_at,
    dateDiff('day', l.created_at, l.converted_at)                  as days_to_convert
from leads as l
left join campaigns as c
    on c.id_campaign = l.campaign_id
