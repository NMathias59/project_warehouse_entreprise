{{ config(tags=['staging', 'procurement']) }}

with source as (

    select * from {{ source('procurement', 'rfqs') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(reference,                _airbyte_extracted_at) as reference,
        argMax(status,                   _airbyte_extracted_at) as status,
        argMax(buyer_id,                 _airbyte_extracted_at) as buyer_id,
        argMax(delivery_date_requested,  _airbyte_extracted_at) as delivery_date_requested,
        argMax(description,              _airbyte_extracted_at) as description,
        argMax(sent_at,                  _airbyte_extracted_at) as sent_at,
        argMax(response_deadline,        _airbyte_extracted_at) as response_deadline,
        argMax(created_at,               _airbyte_extracted_at) as created_at,
        argMax(updated_at,               _airbyte_extracted_at) as updated_at,
        max(_airbyte_extracted_at)                              as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                        as varchar)   as id_rfq,
    cast(coalesce(reference, '')                   as varchar)   as reference,
    cast(coalesce(status, '')                      as varchar)   as status,
    cast(coalesce(buyer_id, '')                    as varchar)   as buyer_id,
    cast(delivery_date_requested                   as date)      as delivery_date_requested,
    cast(coalesce(description, '')                 as varchar)   as description,
    toDateTimeOrNull(toString(sent_at))                          as sent_at,
    toDateTimeOrNull(toString(response_deadline))                as response_deadline,
    cast(created_at                                as timestamp) as created_at,
    toDateTimeOrNull(toString(updated_at))                       as updated_at,
    cast(latest_extracted_at                       as timestamp) as _etl_loaded_at
from deduped
