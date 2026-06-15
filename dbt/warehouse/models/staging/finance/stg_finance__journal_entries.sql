{{ config(tags=['staging', 'finance']) }}

select
    cast(id                                                                                    as varchar)   as id_journal_entry,
    cast(coalesce(argMax(entry_number,    _airbyte_extracted_at), '')                          as varchar)   as reference,
    cast(coalesce(argMax(source,          _airbyte_extracted_at), '')                          as varchar)   as journal_type,
    cast(''                                                                                    as varchar)   as accounting_period_id,
    cast(argMax(entry_date,               _airbyte_extracted_at)                               as date)      as entry_date,
    cast(coalesce(argMax(description,     _airbyte_extracted_at), '')                          as varchar)   as description,
    cast(coalesce(argMax(status,          _airbyte_extracted_at), '')                          as varchar)   as status,
    cast(null                                                                                  as Nullable(DateTime64(3))) as posted_at,
    cast(''                                                                                    as varchar)   as reversed_entry_id,
    cast(coalesce(argMax(created_by,      _airbyte_extracted_at), '')                          as varchar)   as created_by,
    cast(argMax(created_at,               _airbyte_extracted_at)                               as timestamp) as created_at,
    cast(null                                                                                  as Nullable(DateTime64(3))) as updated_at,
    cast(max(_airbyte_extracted_at)                                                            as timestamp) as _etl_loaded_at
from {{ source('finance', 'journal_entries') }}
where id is not null
group by id
