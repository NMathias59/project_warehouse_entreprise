{{ config(
    materialized='table',
    tags=['reports', 'market_place', 'commerce']
) }}

with orders_daily as (

    select
        toDate(order_ordered_at)                    as revenue_day,
        count(distinct order_id)                    as orders_count,
        count(order_line_id)                        as order_lines_count,
        sum(order_line_total_ttc)                   as gross_revenue_ttc,
        countDistinct(order_customer_id)            as unique_customers_count
    from {{ ref('fct_orders') }}
    where order_ordered_at is not null
    group by toDate(order_ordered_at)

),

payments_daily as (

    select
        toDate(payment_paid_at)                                     as revenue_day,
        countIf(payment_status = 'completed')                       as payments_completed_count,
        sumIf(payment_amount, payment_status = 'completed')         as payments_collected_amount,
        countIf(payment_status = 'failed')                          as payments_failed_count
    from {{ ref('fct_payments') }}
    where payment_paid_at is not null
    group by toDate(payment_paid_at)

),

refunds_daily as (

    select
        toDate(refund_created_at)   as revenue_day,
        count(refund_id)            as refunds_count,
        sum(refund_amount)          as refunds_amount
    from {{ ref('fct_refunds') }}
    where refund_created_at is not null
    group by toDate(refund_created_at)

),

final as (

    select
        o.revenue_day                                                   as revenue_day,
        toYear(o.revenue_day)                                           as year,
        toYYYYMM(o.revenue_day)                                         as month,
        toDayOfWeek(o.revenue_day)                                      as day_of_week,
        o.orders_count,
        o.order_lines_count,
        o.unique_customers_count,
        o.gross_revenue_ttc,
        coalesce(p.payments_completed_count, 0)                         as payments_completed_count,
        coalesce(p.payments_collected_amount, 0)                        as payments_collected_amount,
        coalesce(p.payments_failed_count, 0)                            as payments_failed_count,
        coalesce(r.refunds_count, 0)                                    as refunds_count,
        coalesce(r.refunds_amount, 0)                                   as refunds_amount,
        coalesce(p.payments_collected_amount, 0)
            - coalesce(r.refunds_amount, 0)                             as net_revenue,
        if(o.orders_count > 0,
           o.gross_revenue_ttc / o.orders_count, 0)                     as avg_order_value_ttc,
        if(o.orders_count > 0,
           round(coalesce(p.payments_failed_count, 0) / o.orders_count * 100, 2),
           0)                                                           as payment_failure_rate_pct
    from orders_daily o
    left join payments_daily p on o.revenue_day = p.revenue_day
    left join refunds_daily r  on o.revenue_day = r.revenue_day

)

select * from final
