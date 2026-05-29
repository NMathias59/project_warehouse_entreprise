{{ config(tags=['staging', 'erp']) }}

select
    cast(id as varchar)             as id_chart_of_account,
    cast(label as varchar)          as label,
    cast(is_active as boolean)      as is_active,
    cast(parent_id as varchar)      as parent_id,
    cast(created_at as timestamp)   as created_at,
    cast(account_type as varchar)   as account_type,
    cast(account_number as varchar)  as account_number
from {{ source('erp', 'chart_of_accounts') }}
where id is not null