{{ config(tags=['staging', 'finance']) }}

with base as (

    select * from {{ ref('base_finance__journal_entries') }}

)

select
    cast(id                                    as varchar)   as id_journal_entry,
    cast(coalesce(entry_number,    '')         as varchar)   as reference,
    cast(coalesce(source,          '')         as varchar)   as journal_type,
    cast(''                                    as varchar)   as accounting_period_id,
    cast(entry_date                            as date)      as entry_date,
    cast(coalesce(description,     '')         as varchar)   as description,
    cast(coalesce(status,          '')         as varchar)   as status,
    cast(null as Nullable(DateTime64(3)))                    as posted_at,
    cast(''                                    as varchar)   as reversed_entry_id,
    cast(coalesce(created_by,      '')         as varchar)   as created_by,
    cast(created_at                            as timestamp) as created_at,
    cast(null as Nullable(DateTime64(3)))                    as updated_at,
    cast(latest_extracted_at                as timestamp) as _etl_loaded_at
from base
