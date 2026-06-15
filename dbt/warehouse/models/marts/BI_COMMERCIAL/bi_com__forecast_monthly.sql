{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(close_month, territory)',
    settings={'allow_nullable_key': 1},
    tags=['bi', 'commercial']
) }}

select
    toStartOfMonth(o.expected_close_at)                                     as close_month,
    coalesce(sr.territory, '')                                              as territory,
    count(o.id_opportunity)                                                 as nb_opportunities,
    countIf(o.status not in ('won', 'lost'))                                as nb_open,
    countIf(o.status = 'won')                                               as nb_won,
    countIf(o.status = 'lost')                                              as nb_lost,
    round(sum(o.amount_estimated), 2)                                       as total_pipeline_amount,
    round(sum(if(o.status not in ('won', 'lost'),
               o.amount_estimated * o.probability / 100.0, 0)), 2)         as weighted_forecast,
    round(sum(if(o.status = 'won', o.amount_estimated, 0)), 2)             as confirmed_revenue,
    round(countIf(o.status = 'won') * 100.0
          / nullIf(countIf(o.status in ('won', 'lost')), 0), 1)            as win_rate_pct,
    round(avg(o.amount_estimated), 2)                                       as avg_deal_size
from {{ ref('fct_crm_opportunities') }} as o
left join {{ ref('dim_crm_sales_reps') }} as sr
    on sr.id_sales_rep = o.owner_id
where o.expected_close_at is not null
group by
    toStartOfMonth(o.expected_close_at),
    coalesce(sr.territory, '')
