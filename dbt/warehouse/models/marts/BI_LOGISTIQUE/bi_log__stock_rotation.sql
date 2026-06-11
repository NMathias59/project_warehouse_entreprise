{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='tuple()',
    tags=['bi', 'logistique']
) }}

with component_stock as (

    select
        id_component                                                     as component_id,
        component_name,
        unit,
        coalesce(current_stock, 0)                                       as current_stock,
        coalesce(min_stock, 0)                                           as min_stock,
        coalesce(max_stock, 0)                                           as max_stock,
        stock_updated_at
    from {{ ref('dim_components') }}
    where is_active = true

),

inventory_history as (

    select
        component_id,
        count(id_inventory_count_line)                                   as nb_inventory_events,
        minIf(counted_at, counted_at > toDateTime('1970-01-01 00:00:00')) as first_count_at,
        maxIf(counted_at, counted_at > toDateTime('1970-01-01 00:00:00')) as last_count_at,
        sum(abs(variance))                                               as total_variance_abs,
        round(avg(counted_qty), 2)                                       as avg_counted_qty
    from {{ ref('fct_inventory_counts') }}
    where counted_at > toDateTime('1970-01-01 00:00:00')
    group by component_id

),

po_received as (

    select
        r.component_id,
        sum(r.quantity)                                                  as total_qty_received,
        count(distinct r.id_purchase_receipt)                            as nb_receipts,
        maxIf(r.received_at,
              r.received_at > toDateTime('1970-01-01 00:00:00'))         as last_received_at
    from {{ ref('fct_purchase_receipt') }} as r
    where r.received_at > toDateTime('1970-01-01 00:00:00')
    group by r.component_id

)

select
    cs.component_id                                                      as component_id,
    cs.component_name                                                    as component_name,
    cs.unit                                                              as unit,
    cs.current_stock                                                     as current_stock,
    cs.min_stock                                                         as min_stock,
    cs.max_stock                                                         as max_stock,
    cs.stock_updated_at                                                  as stock_updated_at,
    coalesce(pr.total_qty_received, 0)                                   as total_qty_received,
    coalesce(pr.nb_receipts, 0)                                          as nb_receipts,
    pr.last_received_at                                                  as last_received_at,
    coalesce(im.nb_inventory_events, 0)                                  as nb_inventory_events,
    im.first_count_at                                                    as first_count_at,
    im.last_count_at                                                     as last_count_at,
    coalesce(im.avg_counted_qty, 0)                                      as avg_counted_qty,
    coalesce(im.total_variance_abs, 0)                                   as total_variance_abs,
    if(
        coalesce(im.avg_counted_qty, 0) > 0
        and coalesce(pr.total_qty_received, 0) > 0,
        round(pr.total_qty_received / im.avg_counted_qty, 2),
        null
    )                                                                    as stock_turnover_ratio,
    if(
        im.last_count_at is null
        or im.last_count_at = toDateTime('1970-01-01 00:00:00'),
        1, 0
    )                                                                    as is_never_counted,
    if(
        pr.last_received_at is null
        or dateDiff('day', toDate(pr.last_received_at), today()) > 180,
        1, 0
    )                                                                    as is_slow_moving,
    if(cs.current_stock = 0
       and coalesce(pr.total_qty_received, 0) > 0,
        1, 0)                                                            as is_depleted
from component_stock as cs
left join inventory_history as im
    on im.component_id = cs.component_id
left join po_received as pr
    on pr.component_id = cs.component_id
