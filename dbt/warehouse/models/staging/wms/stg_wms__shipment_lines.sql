{{ config(tags=['staging', 'wms']) }}

with source as (

    select * from {{ source('wms', 'shipment_lines') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(shipment_id,  _airbyte_extracted_at) as shipment_id,
        argMax(product_id,   _airbyte_extracted_at) as product_id,
        argMax(location_id,  _airbyte_extracted_at) as location_id,
        argMax(quantity,     _airbyte_extracted_at) as quantity,
        argMax(picked_at,    _airbyte_extracted_at) as picked_at,
        argMax(created_at,   _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                  as latest_extracted_at
    from source
    group by id

)

select
    cast(id                              as varchar)       as id_shipment_line,
    cast(coalesce(shipment_id, '')       as varchar)       as shipment_id,
    cast(coalesce(product_id, '')        as varchar)       as product_id,
    cast(coalesce(location_id, '')       as varchar)       as location_id,
    cast(coalesce(quantity, 0)           as decimal(18,2)) as quantity,
    toDateTimeOrNull(toString(picked_at))                  as picked_at,
    cast(created_at                      as timestamp)     as created_at,
    cast(latest_extracted_at             as timestamp)     as _etl_loaded_at
from deduped
