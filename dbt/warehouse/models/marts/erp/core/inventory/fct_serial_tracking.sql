{{ config(materialized='incremental', unique_key='id_serial_number', incremental_strategy='append', tags=['mart','erp','core'],
           pre_hook=[ clickhouse_delete_existing_rows(ref('stg_erp__serial_numbers'), 'id_serial_number', 'id_serial_number', 'produced_at', 7) ]) }}
{# clickhouse detected: 'merge' strategy may not be supported by the ClickHouse adapter.
   Using 'append' as a compatible incremental strategy. If updates must be applied, implement a
   delete+insert or dedup strategy appropriate for your adapter. #}

with sn as (
    select * from {{ ref('stg_erp__serial_numbers') }}
),
ro as (
    select
        id_repair_order     as repair_order_id,
        description         as repair_reference,
        status              as repair_status,
        received_at,
        resolved_at
    from {{ ref('stg_erp__repair_orders') }}
)

select
    sn.id_serial_number,
    sn.serial,
    sn.status,
    sn.shipped_at,
    sn.produced_at,
    ro.repair_order_id,
    ro.repair_reference,
    ro.repair_status,
    ro.received_at      as repair_received_at,
    ro.resolved_at      as repair_resolved_at
from sn
left join ro on sn.work_order_id = ro.repair_order_id

{% if is_incremental() %}
where coalesce(sn.produced_at, sn.shipped_at) > (select coalesce(max(coalesce(produced_at, shipped_at)), '1970-01-01') from {{ this }})
{% endif %}
