{{ config(tags=['staging', 'erp']) }}

with source as (
    select * from {{ source('erp', 'alembic_version') }}
)

select
    cast(version_num as varchar) as version_num
from source
