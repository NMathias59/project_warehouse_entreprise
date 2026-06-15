{{ config(tags=['staging', 'sav']) }}

with source as (

    select * from {{ source('sav', 'warranties') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(customer_ref,  _airbyte_extracted_at) as customer_id,
        argMax(product_sku,   _airbyte_extracted_at) as product_id,
        argMax(serial_number, _airbyte_extracted_at) as serial_number,
        argMax(warranty_type, _airbyte_extracted_at) as warranty_type,
        argMax(status,        _airbyte_extracted_at) as status,
        argMax(created_at,    _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                   as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                  as varchar)   as id_warranty,
    cast(''                                  as varchar)   as ticket_id,
    cast(coalesce(customer_id, '')           as varchar)   as customer_id,
    cast(coalesce(product_id, '')            as varchar)   as product_id,
    cast(coalesce(serial_number, '')         as varchar)   as serial_number,
    cast(coalesce(warranty_type, '')         as varchar)   as warranty_type,
    cast(coalesce(status, '')                as varchar)   as status,
    cast(''                                  as varchar)   as claim_reason,
    cast(null as Nullable(DateTime64(3)))                  as approved_at,
    cast(''                                  as varchar)   as rejected_reason,
    cast(created_at                          as timestamp) as created_at,
    cast(null as Nullable(DateTime64(3)))                  as updated_at,
    cast(latest_extracted_at                 as timestamp) as _etl_loaded_at
from deduped
