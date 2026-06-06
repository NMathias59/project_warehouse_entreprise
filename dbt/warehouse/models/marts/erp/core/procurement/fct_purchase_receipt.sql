{{ config(materialized='incremental', unique_key='id_purchase_receipt', incremental_strategy='append', tags=['mart','erp','core', 'procurement'],
           pre_hook=[ clickhouse_delete_existing_rows(ref('stg_erp__purchase_receipts'), 'id_purchase_receipt', 'id_purchase_receipt', 'received_at', 7) ]) }}
{# clickhouse detected: 'merge' strategy may not be supported by the ClickHouse adapter.
   Using 'append' as a compatible incremental strategy. If updates must be applied, implement a
   delete+insert or dedup strategy appropriate for your adapter. #}

with pr as (
    select
        id_purchase_receipt
        ,reference
        ,received_at
        ,purchase_order_id
    from {{ ref('stg_erp__purchase_receipts') }}
),
prl as (
    select
        id_purchase_receipt_line
        ,receipt_id
        ,component_id
        ,quantity
        ,condition
    from {{ ref('stg_erp__purchase_receipt_lines') }}
)

select
    pr.id_purchase_receipt as id_purchase_receipt,
    pr.reference,
    pr.received_at,
    pr.purchase_order_id,
    prl.id_purchase_receipt_line as purchase_receipt_line_id,
    prl.component_id,
    prl.quantity,
    prl.condition
from pr
left join prl on pr.id_purchase_receipt = prl.receipt_id

{% if is_incremental() %}
where pr.received_at > (select coalesce(max(received_at), '1970-01-01') from {{ this }})
{% endif %}
