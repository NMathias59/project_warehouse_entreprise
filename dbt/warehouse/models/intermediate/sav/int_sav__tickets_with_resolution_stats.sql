{{ config(materialized='view', tags=['intermediate', 'sav']) }}

select
    t.id_ticket                                                                as id_ticket,
    t.reference                                                                as reference,
    t.title                                                                    as title,
    t.status                                                                   as status,
    t.priority                                                                 as priority,
    t.ticket_type                                                              as ticket_type,
    t.channel                                                                  as channel,
    t.customer_id                                                              as customer_id,
    t.order_id                                                                 as order_id,
    t.product_id                                                               as product_id,
    t.assigned_to                                                              as assigned_to,
    t.created_at                                                               as created_at,
    t.resolved_at                                                              as resolved_at,
    t.closed_at                                                                as closed_at,
    count(tm.id_ticket_message)                                                as nb_messages,
    countIf(tm.sender_type = 'customer')                                       as nb_customer_messages,
    countIf(tm.sender_type = 'agent')                                          as nb_agent_messages,
    count(th.id_ticket_history)                                                as nb_status_changes,
    dateDiff('hour', t.created_at, t.resolved_at)                             as resolution_time_hours,
    minIf(tm.sent_at, tm.sender_type = 'agent')                               as first_response_at,
    dateDiff('minute', t.created_at, minIf(tm.sent_at, tm.sender_type = 'agent')) as first_response_time_minutes
from {{ ref('stg_sav__tickets') }} as t
left join {{ ref('stg_sav__ticket_messages') }} as tm
    on tm.ticket_id = t.id_ticket
left join {{ ref('stg_sav__ticket_history') }} as th
    on th.ticket_id = t.id_ticket
group by
    id_ticket,
    reference,
    title,
    status,
    priority,
    ticket_type,
    channel,
    customer_id,
    order_id,
    product_id,
    assigned_to,
    created_at,
    resolved_at,
    closed_at
