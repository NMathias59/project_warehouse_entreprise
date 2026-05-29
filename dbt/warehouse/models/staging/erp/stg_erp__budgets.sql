{{ config(tags=['staging', 'erp']) }}

with source as (
    select * from {{ source('erp', 'budgets') }}
)

select
    cast(id as varchar)                as id_budget,
    cast(label as varchar)             as label,
    cast(version as varchar)           as version,
    cast(is_active as boolean)         as is_active,
    cast(created_at as timestamp)      as created_at,
    cast(cost_center_id as varchar)    as cost_center_id,
    cast(fiscal_year_id as varchar)    as fiscal_year_id
from source
where id is not null
