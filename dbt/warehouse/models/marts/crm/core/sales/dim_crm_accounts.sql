{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(id_account)',
    tags=['marts', 'crm', 'dim']
) }}

select
    a.id_account,
    a.name,
    a.account_type,
    a.status,
    a.segment,
    a.email,
    a.phone,
    a.website,
    a.city,
    a.country_code,
    a.external_ref,
    a.source_customer_id,
    a.source_supplier_code,
    a.owner_id,
    a.total_orders,
    a.loyalty_balance,
    a.lifetime_value,
    a.last_order_at,
    a.created_at,
    a.updated_at,
    s.nb_activities,
    s.nb_calls,
    s.nb_meetings,
    s.nb_emails,
    s.nb_opportunities,
    s.nb_opp_won,
    s.nb_opp_lost,
    s.revenue_won,
    s.pipeline_amount,
    s.last_activity_at,
    s.nb_tasks
from {{ ref('stg_crm__accounts') }} as a
left join {{ ref('int_crm__accounts_activity_stats') }} as s
    on s.id_account = a.id_account
where a.deleted_at is null
