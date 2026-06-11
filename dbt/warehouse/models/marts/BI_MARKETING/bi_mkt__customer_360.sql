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
    c.total_orders                                                       as total_orders,
    c.first_order_at                                                     as first_order_at,
    c.last_order_at                                                      as last_order_at,
    c.customer_created_at                                                as customer_created_at,
    -- Programme fidélité
    coalesce(lp.current_balance, 0)                                     as loyalty_balance,
    coalesce(lp.total_points_earned, 0)                                 as loyalty_points_earned,
    coalesce(lp.redemption_rate_pct, 0)                                 as loyalty_redemption_rate_pct,
    -- Compte CRM associé
    crm.id_account                                                      as crm_account_id,
    crm.name                                                            as crm_account_name,
    crm.account_type                                                    as crm_account_type,
    crm.status                                                          as crm_status,
    coalesce(crm.lifetime_value, 0)                                     as crm_lifetime_value,
    coalesce(crm.nb_opportunities, 0)                                   as crm_nb_opportunities,
    coalesce(crm.nb_opp_won, 0)                                         as crm_nb_opp_won,
    coalesce(crm.revenue_won, 0)                                        as crm_revenue_won,
    coalesce(crm.pipeline_amount, 0)                                    as crm_pipeline_amount,
    -- Flags et segmentation
    if(c.total_orders > 1, 1, 0)                                        as is_repeat_buyer,
    if(c.last_order_at >= today() - interval 90 day, 1, 0)             as is_active_last_90d,
    if(crm.id_account is not null, 1, 0)                                as has_crm_account,
    if(lp.customer_id is not null, 1, 0)                                as is_in_loyalty_program,
    multiIf(
        c.total_orders = 0, 'prospect',
        c.total_orders = 1, 'new',
        c.total_orders <= 5, 'regular',
        'loyal'
    )                                                                   as customer_segment
from {{ ref('dim_customers') }} as c
left join {{ ref('rpt_mkt__loyalty_program') }} as lp
    on lp.customer_id = c.customer_id
left join {{ ref('dim_crm_accounts') }} as crm
    on crm.source_customer_id = c.customer_id
where c.customer_deleted_at is null
