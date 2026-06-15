{{ config(tags=['staging', 'finance']) }}

select
    cast(id                                                                          as varchar)   as id_bank_account,
    cast(coalesce(argMax(iban,      _airbyte_extracted_at), '')                      as varchar)   as iban,
    cast(coalesce(argMax(bic,       _airbyte_extracted_at), '')                      as varchar)   as bic,
    cast(coalesce(argMax(bank_name, _airbyte_extracted_at), '')                      as varchar)   as bank_name,
    cast(''                                                                          as varchar)   as account_name,
    cast(coalesce(argMax(currency,  _airbyte_extracted_at), '')                      as varchar)   as currency,
    cast(coalesce(argMax(is_active, _airbyte_extracted_at), false)                   as boolean)   as is_active,
    cast(null                                                                        as Nullable(DateTime64(3))) as created_at,
    cast(null                                                                        as Nullable(DateTime64(3))) as updated_at,
    cast(max(_airbyte_extracted_at)                                                  as timestamp) as _etl_loaded_at
from {{ source('finance', 'bank_accounts') }}
where id is not null
group by id
