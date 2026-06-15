{{ config(tags=['staging', 'finance']) }}

with base as (

    select * from {{ ref('base_finance__bank_accounts') }}

)

select
    cast(id                                    as varchar)   as id_bank_account,
    cast(coalesce(iban,      '')               as varchar)   as iban,
    cast(coalesce(bic,       '')               as varchar)   as bic,
    cast(coalesce(bank_name, '')               as varchar)   as bank_name,
    cast(''                                    as varchar)   as account_name,
    cast(coalesce(currency,  '')               as varchar)   as currency,
    cast(coalesce(is_active, false)            as boolean)   as is_active,
    cast(null as Nullable(DateTime64(3)))                    as created_at,
    cast(null as Nullable(DateTime64(3)))                    as updated_at,
    cast(latest_extracted_at                as timestamp) as _etl_loaded_at
from base
