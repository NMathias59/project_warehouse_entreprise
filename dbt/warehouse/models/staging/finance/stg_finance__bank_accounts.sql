{{ config(tags=['staging', 'finance']) }}

with source as (

    select * from {{ source('finance', 'bank_accounts') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(iban,          _airbyte_extracted_at) as iban,
        argMax(bic,           _airbyte_extracted_at) as bic,
        argMax(bank_name,     _airbyte_extracted_at) as bank_name,
        argMax(account_name,  _airbyte_extracted_at) as account_name,
        argMax(currency,      _airbyte_extracted_at) as currency,
        argMax(is_active,     _airbyte_extracted_at) as is_active,
        argMax(created_at,    _airbyte_extracted_at) as created_at,
        argMax(updated_at,    _airbyte_extracted_at) as updated_at,
        max(_airbyte_extracted_at)                   as latest_extracted_at
    from source
    group by id

)

select
    cast(id                               as varchar)   as id_bank_account,
    cast(coalesce(iban, '')               as varchar)   as iban,
    cast(coalesce(bic, '')                as varchar)   as bic,
    cast(coalesce(bank_name, '')          as varchar)   as bank_name,
    cast(coalesce(account_name, '')       as varchar)   as account_name,
    cast(coalesce(currency, '')           as varchar)   as currency,
    cast(coalesce(is_active, false)       as boolean)   as is_active,
    cast(created_at                       as timestamp) as created_at,
    toDateTimeOrNull(toString(updated_at))              as updated_at,
    cast(latest_extracted_at              as timestamp) as _etl_loaded_at
from deduped
