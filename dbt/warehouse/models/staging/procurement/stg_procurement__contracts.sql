{{ config(tags=['staging', 'procurement']) }}

with source as (

    select * from {{ source('procurement', 'contracts') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(reference,      _airbyte_extracted_at) as reference,
        argMax(supplier_id,    _airbyte_extracted_at) as supplier_id,
        argMax(contract_type,  _airbyte_extracted_at) as contract_type,
        argMax(status,         _airbyte_extracted_at) as status,
        argMax(title,          _airbyte_extracted_at) as title,
        argMax(total_amount,   _airbyte_extracted_at) as total_amount,
        argMax(currency,       _airbyte_extracted_at) as currency,
        argMax(start_date,     _airbyte_extracted_at) as start_date,
        argMax(end_date,       _airbyte_extracted_at) as end_date,
        argMax(signed_at,      _airbyte_extracted_at) as signed_at,
        argMax(created_by,     _airbyte_extracted_at) as created_by,
        argMax(created_at,     _airbyte_extracted_at) as created_at,
        argMax(updated_at,     _airbyte_extracted_at) as updated_at,
        max(_airbyte_extracted_at)                    as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                  as varchar)       as id_contract,
    cast(coalesce(reference, '')             as varchar)       as reference,
    cast(coalesce(supplier_id, '')           as varchar)       as supplier_id,
    cast(coalesce(contract_type, '')         as varchar)       as contract_type,
    cast(coalesce(status, '')                as varchar)       as status,
    cast(coalesce(title, '')                 as varchar)       as title,
    cast(coalesce(total_amount, 0)           as decimal(18,2)) as total_amount,
    cast(coalesce(currency, '')              as varchar)       as currency,
    cast(start_date                          as date)          as start_date,
    cast(end_date                            as date)          as end_date,
    toDateTimeOrNull(toString(signed_at))                      as signed_at,
    cast(coalesce(created_by, '')            as varchar)       as created_by,
    cast(created_at                          as timestamp)     as created_at,
    toDateTimeOrNull(toString(updated_at))                     as updated_at,
    cast(latest_extracted_at                 as timestamp)     as _etl_loaded_at
from deduped
