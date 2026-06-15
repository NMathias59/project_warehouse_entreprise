{{ config(tags=['staging', 'finance']) }}

select
    cast(id                                                                             as varchar)       as id_journal_line,
    cast(coalesce(argMax(entry_id,       _airbyte_extracted_at), '')                    as varchar)       as journal_entry_id,
    0                                                                                                     as line_number,
    cast(coalesce(argMax(account_id,     _airbyte_extracted_at), '')                    as varchar)       as account_id,
    cast(coalesce(argMax(cost_center_id, _airbyte_extracted_at), '')                    as varchar)       as cost_center_id,
    cast(coalesce(argMax(description,    _airbyte_extracted_at), '')                    as varchar)       as description,
    cast(coalesce(argMax(debit_eur,      _airbyte_extracted_at), 0)                     as decimal(18,2)) as debit_amount,
    cast(coalesce(argMax(credit_eur,     _airbyte_extracted_at), 0)                     as decimal(18,2)) as credit_amount,
    cast(''                                                                             as varchar)       as currency,
    cast(0                                                                              as decimal(18,6)) as exchange_rate,
    cast(null                                                                           as Nullable(DateTime64(3))) as created_at,
    cast(max(_airbyte_extracted_at)                                                     as timestamp)     as _etl_loaded_at
from {{ source('finance', 'journal_lines') }}
where id is not null
group by id
