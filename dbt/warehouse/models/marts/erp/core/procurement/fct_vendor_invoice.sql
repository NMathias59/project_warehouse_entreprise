{{ config(materialized='incremental', unique_key='id_vendor_invoice', incremental_strategy='append', tags=['mart','erp','core', 'procurement'],
           pre_hook=[ clickhouse_delete_existing_rows(ref('stg_erp__vendor_invoices'), 'id_vendor_invoice', 'id_vendor_invoice', 'issued_at', 7) ]) }}
{# clickhouse detected: 'merge' strategy may not be supported by the ClickHouse adapter.
   Using 'append' as a compatible incremental strategy. Pre-hook deletes existing keys in a recent window.
#}

select
    id_vendor_invoice,
    due_at,
    status,
    paid_at,
    currency,
    total_ht,
    issued_at,
    reference,
    total_ttc,
    created_at,
    supplier_id,
    purchase_order_id
from {{ ref('stg_erp__vendor_invoices') }}

{% if is_incremental() %}
where issued_at > (select coalesce(max(issued_at), '1970-01-01') from {{ this }})
{% endif %}
