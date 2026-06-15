{{ config(tags=['staging', 'crm']) }}

-- Déduplication via argMax — même pattern que stg_crm__accounts.

with base as (

    select * from {{ ref('base_crm__opportunities') }}

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
    cast(latest_extracted_at                as timestamp)     as _etl_loaded_at
from base
