{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='tuple()',
    tags=['bi', 'marketing']
) }}

with newsletters as (

    select
        'newsletter'                                as campaign_type,
        cast(campaign_id as varchar)               as campaign_id,
        subject                                    as campaign_name,
        sent_date                                  as campaign_date,
        toInt64(sent_to_count)                     as audience_size,
        open_rate_pct,
        click_rate_pct,
        0                                          as revenue_generated,
        0                                          as discount_granted
    from {{ ref('rpt_mkt__newsletter_performance') }}
    where sent_date is not null

),

discount_codes as (

    select
        'discount_code'                            as campaign_type,
        cast(discount_code_id as varchar)          as campaign_id,
        code                                       as campaign_name,
        toDate(first_used_at)                      as campaign_date,
        toInt64(actual_uses)                       as audience_size,
        0                                          as open_rate_pct,
        coalesce(usage_rate_pct, 0)                as click_rate_pct,
        coalesce(revenue_with_code, 0)             as revenue_generated,
        coalesce(total_discount_granted, 0)        as discount_granted
    from {{ ref('rpt_mkt__discount_code_performance') }}
    where first_used_at is not null

),

flash_sales as (

    select
        'flash_sale'                               as campaign_type,
        cast(flash_sale_id as varchar)             as campaign_id,
        flash_sale_name                            as campaign_name,
        toDate(flash_sale_starts_at)               as campaign_date,
        toInt64(flash_sale_stock_allocated)        as audience_size,
        0                                          as open_rate_pct,
        coalesce(sell_through_rate_pct, 0)         as click_rate_pct,
        coalesce(estimated_revenue_ttc, 0)         as revenue_generated,
        0                                          as discount_granted
    from {{ ref('rpt_mkt__flash_sales_performance') }}
    where flash_sale_starts_at is not null

)

select * from newsletters
union all
select * from discount_codes
union all
select * from flash_sales
