{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(id_location)',
    tags=['marts', 'wms', 'dim']
) }}

with locations as (
    select
        *
    from {{ ref('stg_wms__locations') }}
)

select
    *
from locations
