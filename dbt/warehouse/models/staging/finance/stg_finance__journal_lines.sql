{{ config(tags=['staging', 'finance']) }}

with base as (

    select * from {{ ref('base_finance__journal_lines') }}

)

select
    cast(id                                    as varchar)       as id_journal_line,
    cast(coalesce(entry_id,       '')          as varchar)       as journal_entry_id,
    0                                                            as line_number,
    cast(coalesce(account_id,     '')          as varchar)       as account_id,
    cast(coalesce(cost_center_id, '')          as varchar)       as cost_center_id,
    cast(coalesce(description,    '')          as varchar)       as description,
    cast(coalesce(debit_eur,      0)           as decimal(18,2)) as debit_amount,
    cast(coalesce(credit_eur,     0)           as decimal(18,2)) as credit_amount,
    cast(''                                    as varchar)       as currency,
    cast(0                                     as decimal(18,6)) as exchange_rate,
    cast(null as Nullable(DateTime64(3)))                        as created_at,
    cast(latest_extracted_at                as timestamp)     as _etl_loaded_at
from base
