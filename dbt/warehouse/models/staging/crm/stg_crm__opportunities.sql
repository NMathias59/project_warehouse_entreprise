{{ config(tags=['staging', 'crm']) }}

-- Déduplication via argMax — même pattern que stg_crm__accounts.

with source as (

    select * from {{ source('crm', 'opportunities') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(title,             _airbyte_extracted_at) as title,
        argMax(stage,             _airbyte_extracted_at) as stage,
        argMax(status,            _airbyte_extracted_at) as status,
        argMax(origin,            _airbyte_extracted_at) as origin,
        argMax(notes,             _airbyte_extracted_at) as notes,
        argMax(account_id,        _airbyte_extracted_at) as account_id,
        argMax(owner_id,          _airbyte_extracted_at) as owner_id,
        argMax(source_order_id,   _airbyte_extracted_at) as source_order_id,
        argMax(probability,       _airbyte_extracted_at) as probability,
        argMax(amount_estimated,  _airbyte_extracted_at) as amount_estimated,
        argMax(expected_close_at, _airbyte_extracted_at) as expected_close_at,
        argMax(created_at,        _airbyte_extracted_at) as created_at,
        argMax(updated_at,        _airbyte_extracted_at) as updated_at,
        max(_airbyte_extracted_at)                       as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                as varchar)       as id_opportunity,
    cast(coalesce(title, '')               as varchar)       as title,
    cast(coalesce(stage, '')               as varchar)       as stage,
    cast(coalesce(status, '')              as varchar)       as status,
    cast(coalesce(origin, '')              as varchar)       as origin,
    cast(coalesce(notes, '')               as varchar)       as notes,
    cast(coalesce(account_id, '')          as varchar)       as account_id,
    cast(coalesce(owner_id, '')            as varchar)       as owner_id,
    cast(coalesce(source_order_id, '')     as varchar)       as source_order_id,
    coalesce(probability, 0)                                 as probability,
    cast(coalesce(amount_estimated, 0)     as decimal(18,2)) as amount_estimated,
    toDateOrNull(toString(expected_close_at))                as expected_close_at,
    cast(created_at                        as timestamp)     as created_at,
    toDateTimeOrNull(toString(updated_at))                   as updated_at,
    cast(latest_extracted_at               as timestamp)     as _etl_loaded_at
from deduped
