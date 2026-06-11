{{
    config(
        materialized='incremental',
        unique_key='payment_id',
        incremental_strategy='append',
        tags=['mart', 'market_place', 'commerce'],
        order_by='(tuple())',
        pre_hook=[
            "{{ clickhouse_delete_existing_rows(ref('stg_mkt__payments'), 'payment_id', 'payment_id', 'payment_paid_at', 7) }}"
        ]
    )
}}

with payments as (

    select
        payment_id,
        payment_order_id,
        payment_amount,
        payment_currency,
        payment_status,
        payment_gateway_ref,
        payment_payment_method_id,
        payment_paid_at,
        payment_created_at
    from {{ ref('stg_mkt__payments') }}

)

select * from payments

{% if is_incremental() %}
where payment_paid_at > (select coalesce(max(payment_paid_at), toDateTime64('1970-01-01 00:00:00', 3)) from {{ this }})
{% endif %}
