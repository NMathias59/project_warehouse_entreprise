{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(id_receipt_line, received_at)',
    tags=['marts', 'wms', 'fct']
) }}

with source as (
    select * from {{ ref('int_wms__receipts_with_lines') }}
)

select
    *
from source
