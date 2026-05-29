{{ config(tags=['staging', 'erp']) }}

select
    cast(id as varchar)             as id,
    cast(id as varchar)             as id_bank_account,
    cast(bic as varchar)            as bic,
    cast(iban as varchar)           as iban,
    cast(name as varchar)           as name,
    cast(currency as varchar)       as currency,
    cast(is_active as boolean)      as is_active,
    cast(created_at as timestamp)   as created_at
from {{ source('erp', 'bank_accounts') }}
where id is not null
