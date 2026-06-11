{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='tuple()',
    tags=['bi', 'marketing']
) }}

with cohorts as (

    select
        customer_id,
        toStartOfMonth(customer_created_at)                              as acquisition_month
    from {{ ref('dim_customers') }}
    where customer_deleted_at is null
      and customer_created_at is not null

),

orders as (

    select
        order_customer_id                                                as customer_id,
        toStartOfMonth(order_ordered_at)                                 as order_month
    from {{ ref('stg_mkt__orders') }}
    where order_deleted_at is null
      and order_status not in ('cancelled', 'refunded')
      and order_ordered_at is not null

),

cohort_sizes as (

    select
        acquisition_month,
        count(customer_id)                                               as cohort_size
    from cohorts
    group by acquisition_month

),

cohort_activity as (

    select
        c.acquisition_month,
        o.order_month,
        dateDiff('month', c.acquisition_month, o.order_month)           as months_since_acquisition,
        count(distinct c.customer_id)                                    as active_customers
    from cohorts as c
    inner join orders as o
        on o.customer_id = c.customer_id
    where o.order_month >= c.acquisition_month
    group by c.acquisition_month, o.order_month

)

select
    toYYYYMM(ca.acquisition_month)                                       as acquisition_month,
    cs.cohort_size,
    ca.months_since_acquisition,
    ca.active_customers,
    round(ca.active_customers * 100.0 / nullIf(cs.cohort_size, 0), 2)   as retention_rate_pct
from cohort_activity as ca
inner join cohort_sizes as cs
    on cs.acquisition_month = ca.acquisition_month
where ca.months_since_acquisition >= 0
