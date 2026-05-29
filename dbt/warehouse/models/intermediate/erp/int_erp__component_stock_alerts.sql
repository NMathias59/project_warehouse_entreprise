{{ config(materialized='ephemeral', tags=['intermediate', 'erp']) }}

with stock as (
    select * from {{ ref('stg_erp__component_stock') }}
),
components as (
    select * from {{ ref('stg_erp__components') }}
)

select
    c.id_components as component_id,
    c.name as component_name,
    c.min_stock,
    sum(s.quantity) as total_stock,
    case when sum(s.quantity) < c.min_stock then true else false end as is_below_min
from components c
left join stock s on c.id_components = s.component_id
group by c.id_components, c.name, c.min_stock

