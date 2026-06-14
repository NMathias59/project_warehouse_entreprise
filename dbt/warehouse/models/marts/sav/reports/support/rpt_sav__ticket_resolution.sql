{{ config(materialized='table', engine='MergeTree()', order_by='(created_at)', tags=['reports','sav','support']) }}
with tickets as (
    select
        id_ticket, reference, title, status, priority, ticket_type, channel,
        customer_id, order_id, product_id, assigned_to,
        nb_messages, nb_customer_messages, nb_agent_messages,
        resolution_time_hours, first_response_time_minutes, nb_status_changes,
        created_at, resolved_at, closed_at
    from {{ ref('fct_sav_tickets') }}
),
technicians as (
    select id_technician, code, first_name, last_name, specialization
    from {{ ref('dim_sav_technicians') }}
),
final as (
    select
        t.id_ticket,
        t.reference,
        t.title,
        t.status,
        t.priority,
        t.ticket_type,
        t.channel,
        t.customer_id,
        t.product_id,
        t.assigned_to,
        tech.first_name                                         as technician_first_name,
        tech.last_name                                          as technician_last_name,
        tech.specialization                                     as technician_specialization,
        t.nb_messages,
        t.nb_customer_messages,
        t.nb_agent_messages,
        t.nb_status_changes,
        t.resolution_time_hours,
        t.first_response_time_minutes,
        t.created_at,
        t.resolved_at,
        t.closed_at
    from tickets as t
    left join technicians as tech on tech.id_technician = t.assigned_to
)
select * from final
