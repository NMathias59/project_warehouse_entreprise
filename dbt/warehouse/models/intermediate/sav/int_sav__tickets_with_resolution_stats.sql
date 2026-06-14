{{ config(materialized='ephemeral', tags=['intermediate', 'sav']) }}

with tickets as (
    select * from {{ ref('stg_sav__tickets') }}
),

ticket_messages as (
    select * from {{ ref('stg_sav__ticket_messages') }}
),

ticket_history as (
    select * from {{ ref('stg_sav__ticket_history') }}
)

select
    t.id_ticket,
    t.reference,
    t.title,
    t.status,
    t.priority,
    t.ticket_type,
    t.channel,
    t.customer_id,
    t.order_id,
    t.product_id,
    t.assigned_to,
    t.created_at,
    t.resolved_at,
    t.closed_at,
    count(tm.id_message)                                                            as nb_messages,
    countIf(tm.sender_type = 'customer')                                            as nb_customer_messages,
    countIf(tm.sender_type = 'agent')                                               as nb_agent_messages,
    count(th.id_history)                                                            as nb_status_changes,
    dateDiff('hour', t.created_at, t.resolved_at)                                  as resolution_time_hours,
    minIf(tm.sent_at, tm.sender_type = 'agent')                                    as first_response_at,
    dateDiff('minute', t.created_at, minIf(tm.sent_at, tm.sender_type = 'agent'))  as first_response_time_minutes
from tickets as t
left join ticket_messages as tm
    on tm.ticket_id = t.id_ticket
left join ticket_history as th
    on th.ticket_id = t.id_ticket
group by
    t.id_ticket,
    t.reference,
    t.title,
    t.status,
    t.priority,
    t.ticket_type,
    t.channel,
    t.customer_id,
    t.order_id,
    t.product_id,
    t.assigned_to,
    t.created_at,
    t.resolved_at,
    t.closed_at
