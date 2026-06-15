{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(id_shipment_line, shipped_at)',
    settings={'allow_nullable_key': 1},
    tags=['marts', 'wms', 'fct']
) }}

with source as (
    select * from {{ ref('int_wms__shipments_with_lines') }}
)

select
    *
from source
