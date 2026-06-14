{{ config(tags=['staging', 'finance']) }}

with source as (

    select * from {{ source('finance', 'journal_entries') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(reference,              _airbyte_extracted_at) as reference,
        argMax(journal_type,           _airbyte_extracted_at) as journal_type,
        argMax(accounting_period_id,   _airbyte_extracted_at) as accounting_period_id,
        argMax(entry_date,             _airbyte_extracted_at) as entry_date,
        argMax(description,            _airbyte_extracted_at) as description,
        argMax(status,                 _airbyte_extracted_at) as status,
        argMax(posted_at,              _airbyte_extracted_at) as posted_at,
        argMax(reversed_entry_id,      _airbyte_extracted_at) as reversed_entry_id,
        argMax(created_by,             _airbyte_extracted_at) as created_by,
        argMax(created_at,             _airbyte_extracted_at) as created_at,
        argMax(updated_at,             _airbyte_extracted_at) as updated_at,
        max(_airbyte_extracted_at)                            as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                    as varchar)   as id_journal_entry,
    cast(coalesce(reference, '')               as varchar)   as reference,
    cast(coalesce(journal_type, '')            as varchar)   as journal_type,
    cast(coalesce(accounting_period_id, '')    as varchar)   as accounting_period_id,
    cast(entry_date                            as date)      as entry_date,
    cast(coalesce(description, '')             as varchar)   as description,
    cast(coalesce(status, '')                  as varchar)   as status,
    toDateTimeOrNull(toString(posted_at))                    as posted_at,
    cast(coalesce(reversed_entry_id, '')       as varchar)   as reversed_entry_id,
    cast(coalesce(created_by, '')              as varchar)   as created_by,
    cast(created_at                            as timestamp) as created_at,
    toDateTimeOrNull(toString(updated_at))                   as updated_at,
    cast(latest_extracted_at                   as timestamp) as _etl_loaded_at
from deduped
