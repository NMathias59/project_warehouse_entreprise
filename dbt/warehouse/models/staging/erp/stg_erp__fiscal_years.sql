{{ config(tags=['staging', 'erp']) }}

with source as (
	select * from {{ source('erp', 'fiscal_years') }}
)

select
	cast(id as varchar)                 as id_fiscal_year,
	cast(label as varchar)              as label,
	cast(ends_at as date)               as ends_at,
	cast(is_closed as boolean)          as is_closed,
	cast(starts_at as date)             as starts_at,
	cast(created_at as timestamp)       as created_at
from source
where id is not null
