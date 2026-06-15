{{ config(tags=['staging', 'procurement']) }}

with source as (

    select * from {{ source('procurement', 'rfq_responses') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(rfq_id,         _airbyte_extracted_at) as rfq_id,
        argMax(supplier_id,    _airbyte_extracted_at) as supplier_id,
        argMax(unit_price_eur, _airbyte_extracted_at) as unit_price,
        argMax(lead_time_days, _airbyte_extracted_at) as lead_time_days,
        argMax(notes,          _airbyte_extracted_at) as notes,
        argMax(received_at,    _airbyte_extracted_at) as received_at,
        max(_airbyte_extracted_at)                    as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                  as varchar)       as id_rfq_response,
    cast(coalesce(rfq_id, '')                as varchar)       as rfq_id,
    cast(coalesce(supplier_id, '')           as varchar)       as supplier_id,
    cast(''                                  as varchar)       as status,
    cast(coalesce(unit_price, 0)             as decimal(18,2)) as unit_price,
    coalesce(lead_time_days, 0)                                as lead_time_days,
    cast(coalesce(notes, '')                 as varchar)       as notes,
    toDateTimeOrNull(toString(received_at))                    as received_at,
    cast(received_at                         as timestamp)     as created_at,
    cast(latest_extracted_at                 as timestamp)     as _etl_loaded_at
from deduped
