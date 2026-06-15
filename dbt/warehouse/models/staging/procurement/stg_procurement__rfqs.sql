{{ config(tags=['staging', 'procurement']) }}

with source as (

    select * from {{ source('procurement', 'rfqs') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(rfq_number,     _airbyte_extracted_at) as reference,
        argMax(status,         _airbyte_extracted_at) as status,
        argMax(requester_ref,  _airbyte_extracted_at) as buyer_id,
        argMax(deadline,       _airbyte_extracted_at) as delivery_date_requested,
        argMax(description,    _airbyte_extracted_at) as description,
        argMax(created_at,     _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                    as latest_extracted_at
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
    cast(null as Nullable(DateTime64(3)))                        as sent_at,
    cast(delivery_date_requested                   as date)      as response_deadline,
    cast(created_at                                as timestamp) as created_at,
    cast(null as Nullable(DateTime64(3)))                        as updated_at,
    cast(latest_extracted_at                       as timestamp) as _etl_loaded_at
from deduped
