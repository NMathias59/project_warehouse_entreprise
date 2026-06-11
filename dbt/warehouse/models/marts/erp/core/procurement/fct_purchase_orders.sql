{{
    config(
        materialized='incremental',
        unique_key='id_purchase_order',
        incremental_strategy='append',
        on_schema_change='sync_all_columns',
        tags=['mart', 'erp', 'core', 'procurement'],
        pre_hook=[
            "{{ clickhouse_delete_existing_rows(ref('stg_erp__purchase_orders'), 'id_purchase_order', 'id_purchase_order', 'ordered_at', 7) }}"
        ]
    )
}}

{# clickhouse detected: 'merge' strategy may not be supported by the ClickHouse adapter.
   Using 'append' as a compatible incremental strategy. If updates must be applied, the pre_hook
   above will delete existing rows with keys present in the source recent window before inserting.
   Verify privileges and syntax for your ClickHouse deployment. #}

with pol as (
    select
        id_purchase_order_line,
        purchase_order_id,
        quantity,
        total_ht,
        unit_price,
        component_id
    from {{ ref('stg_erp__purchase_order_lines') }}
),
po as (
    select
        id_purchase_order,
        status,
        currency,
        created_at,
        ordered_at,
        expected_at,
        supplier_id
    from {{ ref('stg_erp__purchase_orders') }}
),
products as (
    select
        id_product,
        name
    from {{ ref('stg_erp__products') }}
),
suppliers as (
    select
        id_supplier,
        name
    from {{ ref('stg_erp__suppliers') }}
),
base as (
    select
        po.id_purchase_order,
        po.status,
        po.currency,
        po.created_at,
        po.ordered_at,
        po.expected_at,
        po.supplier_id,
        s.name as supplier_name,
        pol.id_purchase_order_line,
        pol.quantity,
        pol.total_ht as line_total_ht,
        pol.unit_price,
        pol.component_id,
        pr.name as product_name
    from po
    left join pol on po.id_purchase_order = pol.purchase_order_id
    left join suppliers s on po.supplier_id = s.id_supplier
    left join products pr on pol.component_id = pr.id_product
)

select
    id_purchase_order,
    status,
    currency,
    created_at,
    ordered_at,
    expected_at,
    supplier_id,
    supplier_name,
    id_purchase_order_line,
    quantity,
    line_total_ht,
    unit_price,
    component_id,
    product_name
from base

{% if is_incremental() %}
where ordered_at > (select coalesce(max(ordered_at), '1970-01-01') from {{ this }})
{% endif %}