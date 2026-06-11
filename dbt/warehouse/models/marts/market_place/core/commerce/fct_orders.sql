{{
    config(
        materialized='incremental',
        unique_key='order_line_id',
        incremental_strategy='append',
        tags=['mart', 'market_place', 'commerce'],
        order_by='(tuple())',
        pre_hook=[
            "{{ clickhouse_delete_existing_rows(ref('stg_mkt__orders'), 'order_id', 'order_id', 'order_ordered_at', 7) }}"
        ]
    )
}}

{# ClickHouse: stratégie append + pre_hook de purge sur fenêtre glissante 7 jours. #}

with orders as (

    select
        order_id,
        order_status,
        order_currency,
        order_reference,
        order_customer_id,
        order_total_ttc,
        order_subtotal_ttc,
        order_discount_ttc,
        order_shipping_ttc,
        order_ordered_at,
        order_deleted_at
    from {{ ref('stg_mkt__orders') }}

),

order_lines as (

    select
        order_line_id,
        order_line_order_id,
        order_line_product_id,
        order_line_product_name,
        order_line_product_sku,
        order_line_quantity,
        order_line_unit_price_ht,
        order_line_unit_price_ttc,
        order_line_vat_rate,
        order_line_total_ttc,
        order_line_created_at
    from {{ ref('stg_mkt__order_lines') }}

),

final as (

    select
        order_lines.order_line_id,
        orders.order_id,
        orders.order_status,
        orders.order_currency,
        orders.order_reference,
        orders.order_customer_id,
        orders.order_total_ttc,
        orders.order_subtotal_ttc,
        orders.order_discount_ttc,
        orders.order_shipping_ttc,
        order_lines.order_line_product_id,
        order_lines.order_line_product_name,
        order_lines.order_line_product_sku,
        order_lines.order_line_quantity,
        order_lines.order_line_unit_price_ht,
        order_lines.order_line_unit_price_ttc,
        order_lines.order_line_vat_rate,
        order_lines.order_line_total_ttc,
        orders.order_ordered_at,
        order_lines.order_line_created_at
    from orders
    inner join order_lines on orders.order_id = order_lines.order_line_order_id

)

select * from final

{% if is_incremental() %}
where order_ordered_at > (select coalesce(max(order_ordered_at), toDateTime64('1970-01-01 00:00:00', 3)) from {{ this }})
{% endif %}
