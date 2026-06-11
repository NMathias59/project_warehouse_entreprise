{{ config(
    materialized='table',
    tags=['reports', 'market_place', 'customer_service']
) }}

with customers as (

    select
        customer_id,
        customer_first_name,
        customer_last_name,
        total_orders,
        first_order_at,
        last_order_at,
        customer_created_at,
        customer_deleted_at
    from {{ ref('dim_customers') }}

),

reviews_agg as (

    select
        review_customer_id,
        count(review_id)                                            as reviews_count,
        round(avg(review_rating), 2)                               as avg_rating,
        countIf(review_rating >= 4)                                 as positive_reviews_count,
        countIf(review_rating <= 2)                                 as negative_reviews_count,
        countIf(review_is_verified = true)                          as verified_reviews_count,
        max(review_created_at)                                      as last_review_at
    from {{ ref('fct_reviews') }}
    where review_deleted_at is null and review_customer_id is not null
    group by review_customer_id

),

tickets_agg as (

    select
        support_ticket_customer_id,
        count(support_ticket_id)                                    as tickets_count,
        countIf(support_ticket_status = 'resolved')                 as resolved_tickets_count,
        countIf(support_ticket_priority in ('high', 'urgent'))      as high_priority_tickets_count,
        avgIf(
            dateDiff('day', support_ticket_created_at, support_ticket_resolved_at),
            support_ticket_resolved_at is not null and support_ticket_created_at is not null
        )                                                           as avg_resolution_days,
        max(support_ticket_created_at)                              as last_ticket_at
    from {{ ref('fct_support_tickets') }}
    where support_ticket_deleted_at is null
    group by support_ticket_customer_id

),

final as (

    select
        c.customer_id,
        c.customer_first_name,
        c.customer_last_name,
        c.total_orders,
        c.first_order_at,
        c.last_order_at,
        c.customer_created_at,
        if(c.customer_deleted_at is null, 1, 0)                     as is_active,
        coalesce(r.reviews_count, 0)                                as reviews_count,
        coalesce(r.avg_rating, 0)                                   as avg_rating,
        coalesce(r.positive_reviews_count, 0)                       as positive_reviews_count,
        coalesce(r.negative_reviews_count, 0)                       as negative_reviews_count,
        coalesce(r.verified_reviews_count, 0)                       as verified_reviews_count,
        r.last_review_at,
        coalesce(t.tickets_count, 0)                                as tickets_count,
        coalesce(t.resolved_tickets_count, 0)                       as resolved_tickets_count,
        coalesce(t.high_priority_tickets_count, 0)                  as high_priority_tickets_count,
        t.avg_resolution_days,
        t.last_ticket_at,
        if(t.tickets_count > 0,
           round(t.resolved_tickets_count / t.tickets_count * 100, 1),
           null)                                                    as ticket_resolution_rate_pct,
        case
            when coalesce(r.avg_rating, 0) >= 4 and coalesce(t.tickets_count, 0) = 0   then 'satisfied'
            when coalesce(r.avg_rating, 0) >= 4 and coalesce(t.tickets_count, 0) > 0   then 'satisfied_with_issues'
            when coalesce(r.avg_rating, 0) > 0 and r.avg_rating < 3                    then 'dissatisfied'
            when coalesce(t.high_priority_tickets_count, 0) > 0                         then 'at_risk'
            else 'neutral'
        end                                                         as satisfaction_segment
    from customers c
    left join reviews_agg r on c.customer_id = r.review_customer_id
    left join tickets_agg t  on c.customer_id = t.support_ticket_customer_id

)

select * from final
