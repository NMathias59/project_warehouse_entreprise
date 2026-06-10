{{
    config(
        materialized='incremental',
        unique_key='shipment_id',
        incremental_strategy='append',
        tags=['mart', 'market_place', 'logistics'],
        order_by='(shipment_shipped_at, shipment_id)',
        pre_hook=[
            "{{ clickhouse_delete_existing_rows(ref('stg_mkt__shipments'), 'shipment_id', 'shipment_id', 'shipment_shipped_at', 7) }}"
        ]
    )
}}

with shipments as (

    select
        shipment_id,
        shipment_order_id,
        shipment_carrier_id,
        shipment_status,
        shipment_tracking_number,
        shipment_shipped_at,
        shipment_delivered_at,
        shipment_created_at
    from {{ ref('stg_mkt__shipments') }}

),

carriers as (

    select
        carrier_id,
        carrier_name
    from {{ ref('stg_mkt__carriers') }}

),

final as (

    select
        shipments.shipment_id,
        shipments.shipment_order_id,
        shipments.shipment_carrier_id,
        carriers.carrier_name,
        shipments.shipment_status,
        shipments.shipment_tracking_number,
        shipments.shipment_shipped_at,
        shipments.shipment_delivered_at,
        shipments.shipment_created_at
    from shipments
    left join carriers on shipments.shipment_carrier_id = carriers.carrier_id

)

select * from final

{% if is_incremental() %}
where shipment_shipped_at > (select coalesce(max(shipment_shipped_at), '1970-01-01') from {{ this }})
{% endif %}
