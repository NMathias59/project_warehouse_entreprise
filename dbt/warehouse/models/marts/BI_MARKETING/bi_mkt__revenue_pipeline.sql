{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(revenue_date)',
    tags=['bi', 'marketing']
) }}

with confirmed_revenue as (

    select
        toDate(order_ordered_at)                    as revenue_date,
        count(distinct order_id)                   as orders_placed,
        sum(order_total_ttc)                       as mkt_revenue_ttc
    from {{ ref('stg_mkt__orders') }}
    where order_deleted_at is null
      and order_status not in ('cancelled', 'refunded')
      and order_ordered_at is not null
    group by toDate(order_ordered_at)

),

crm_pipeline as (

    select
        toDate(created_at)                          as revenue_date,
        count(id_opportunity)                      as new_opportunities,
        sum(amount_estimated)                      as pipeline_added,
        countIf(status = 'won')                    as deals_won,
        sumIf(amount_estimated, status = 'won')    as crm_revenue_won
    from {{ ref('fct_crm_opportunities') }}
    where created_at is not null
    group by toDate(created_at)

),

-- ClickHouse join_use_nulls=0 : FULL OUTER JOIN remplace NULL par '1970-01-01' pour les colonnes
-- Date, ce qui casse coalesce() sur la clé de jointure. On contourne avec UNION + LEFT JOIN.
all_dates as (

    select revenue_date from confirmed_revenue
    union distinct
    select revenue_date from crm_pipeline

)

select
    assumeNotNull(d.revenue_date)                  as revenue_date,
    coalesce(r.orders_placed, 0)                   as orders_placed,
    coalesce(r.mkt_revenue_ttc, 0)                 as mkt_revenue_ttc,
    coalesce(p.new_opportunities, 0)               as new_crm_opportunities,
    coalesce(p.pipeline_added, 0)                  as crm_pipeline_added,
    coalesce(p.deals_won, 0)                       as crm_deals_won,
    coalesce(p.crm_revenue_won, 0)                 as crm_revenue_won,
    coalesce(r.mkt_revenue_ttc, 0)
        + coalesce(p.crm_revenue_won, 0)           as total_revenue_combined
from all_dates as d
left join confirmed_revenue as r on r.revenue_date = d.revenue_date
left join crm_pipeline as p      on p.revenue_date = d.revenue_date
