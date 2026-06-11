{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='tuple()',
    tags=['bi', 'marketing']
) }}

select
    c.customer_id                                                        as customer_id,
    c.customer_first_name                                                as customer_first_name,
    c.customer_last_name                                                 as customer_last_name,
    coalesce(c.total_orders, 0)                                          as total_orders,
    c.first_order_at                                                     as first_order_at,
    c.last_order_at                                                      as last_order_at,
    c.customer_created_at                                                as customer_created_at,
    if(c.last_order_at is not null,
       dateDiff('day', toDate(c.last_order_at), today()),
       null)                                                             as days_since_last_order,
    if(coalesce(c.total_orders, 0) = 0 and c.customer_created_at is not null,
       dateDiff('day', toDate(c.customer_created_at), today()),
       null)                                                             as days_since_signup_no_order,
    coalesce(lp.current_balance, 0)                                      as loyalty_balance,
    coalesce(lp.total_points_earned, 0)                                  as loyalty_points_earned,
    multiIf(
        coalesce(c.total_orders, 0) = 0,                                'never_ordered',
        c.last_order_at is null,                                        'never_ordered',
        dateDiff('day', toDate(c.last_order_at), today()) <= 90,        'active',
        dateDiff('day', toDate(c.last_order_at), today()) <= 180,       'at_risk',
        dateDiff('day', toDate(c.last_order_at), today()) <= 365,       'churning',
                                                                        'churned'
    )                                                                    as churn_status,
    multiIf(
        coalesce(c.total_orders, 0) = 0,                                3,
        c.last_order_at is null,                                        3,
        dateDiff('day', toDate(c.last_order_at), today()) <= 90,        0,
        dateDiff('day', toDate(c.last_order_at), today()) <= 180,       1,
        dateDiff('day', toDate(c.last_order_at), today()) <= 365,       2,
                                                                        3
    )                                                                    as churn_score,
    if(lp.customer_id is not null, 1, 0)                                as is_in_loyalty_program,
    if(crm.id_account is not null, 1, 0)                                as has_crm_account,
    coalesce(crm.pipeline_amount, 0)                                    as crm_open_pipeline
from {{ ref('dim_customers') }} as c
left join {{ ref('rpt_mkt__loyalty_program') }} as lp
    on lp.customer_id = c.customer_id
left join {{ ref('dim_crm_accounts') }} as crm
    on crm.source_customer_id = c.customer_id
where c.customer_deleted_at is null
