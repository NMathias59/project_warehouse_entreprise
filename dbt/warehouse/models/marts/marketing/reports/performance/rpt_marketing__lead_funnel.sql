{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(created_at)',
    settings={'allow_nullable_key': 1},
    tags=['reports', 'marketing', 'performance']
) }}

with leads as (
    select
        id_lead,
        email,
        lead_source,
        status,
        score,
        campaign_id,
        converted_at,
        days_to_convert,
        created_at
    from {{ ref('fct_marketing_leads') }}
),

campaigns as (
    select
        id_campaign,
        name    as campaign_name,
        campaign_type,
        channel
    from {{ ref('dim_marketing_campaigns') }}
),

final as (
    select
        l.id_lead,
        l.email,
        l.lead_source,
        l.status,
        l.score,
        l.campaign_id,
        c.campaign_name,
        c.campaign_type,
        c.channel,
        l.converted_at,
        l.days_to_convert,
        l.created_at
    from leads as l
    left join campaigns as c on c.id_campaign = l.campaign_id
)

select * from final
