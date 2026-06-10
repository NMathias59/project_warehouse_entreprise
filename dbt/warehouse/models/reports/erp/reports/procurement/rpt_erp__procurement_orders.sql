{{ config(
    materialized='table',
    tags=['reports', 'erp', 'procurement']
) }}

with purchase_orders as (

    select
        id_purchase_order,
        id_purchase_order_line,
        status,
        currency,
        ordered_at,
        expected_at,
        supplier_id,
        supplier_name,
        component_id,
        product_name,
        quantity,
        unit_price,
        line_total_ht
    from {{ ref('fct_purchase_orders') }}

),

suppliers as (

    select
        id_supplier,
        country                 as supplier_country,
        is_active               as supplier_is_active,
        nb_purchase_orders      as supplier_total_orders,
        total_purchase_ht       as supplier_total_spend_ht
    from {{ ref('dim_suppliers') }}

),

receipt_summary as (

    select
        purchase_order_id,
        count(distinct id_purchase_receipt)     as receipts_count,
        min(received_at)                        as first_received_at,
        sum(quantity)                           as total_received_qty
    from {{ ref('fct_purchase_receipt') }}
    group by purchase_order_id

),

final as (

    select
        po.id_purchase_order,
        po.id_purchase_order_line,
        po.status,
        po.currency,
        po.ordered_at,
        po.expected_at,
        toDate(po.ordered_at)                                       as ordered_date,
        toYYYYMM(toDate(po.ordered_at))                             as ordered_month,
        po.supplier_id,
        po.supplier_name,
        s.supplier_country,
        s.supplier_is_active,
        s.supplier_total_orders,
        s.supplier_total_spend_ht,
        po.component_id,
        po.product_name,
        po.quantity,
        po.unit_price,
        po.line_total_ht,
        coalesce(r.receipts_count, 0)                               as receipts_count,
        r.first_received_at,
        coalesce(r.total_received_qty, 0)                           as total_received_qty,
        if(r.first_received_at is not null and po.ordered_at is not null,
           dateDiff('day', po.ordered_at, r.first_received_at),
           null)                                                     as days_to_receipt,
        if(r.first_received_at is not null and po.expected_at is not null,
           if(r.first_received_at <= po.expected_at, 1, 0),
           null)                                                     as is_on_time,
        case
            when r.receipts_count > 0 then 'received'
            when po.status = 'cancelled' then 'cancelled'
            else 'pending'
        end                                                          as receipt_status
    from purchase_orders po
    left join suppliers s       on po.supplier_id      = s.id_supplier
    left join receipt_summary r on po.id_purchase_order = r.purchase_order_id

)

select * from final
