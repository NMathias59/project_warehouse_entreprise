{{ config(materialized='ephemeral', tags=['intermediate', 'erp']) }}

with po as (
    select * from {{ ref('stg_erp__purchase_orders') }}
)

select
    status,
    count(*) as nb_orders,
    sum(total_ht) as total_ht
from po
group by status

