{{
    config(
        materialized='table',
        tags=['mart', 'market_place', 'customer_service'],
        order_by='(support_ticket_created_at, support_ticket_id)'
    )
}}

with support_tickets as (

    select
        support_ticket_id,
        support_ticket_customer_id,
        support_ticket_order_id,
        support_ticket_subject,
        support_ticket_status,
        support_ticket_priority,
        support_ticket_created_at,
        support_ticket_resolved_at,
        support_ticket_deleted_at
    from {{ ref('stg_mkt__support_tickets') }}

)

select * from support_tickets
