{{ config(tags=['staging', 'sav']) }}

with base as (

    select * from {{ ref('base_sav__warranties') }}

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
    cast(latest_extracted_at                as timestamp) as _etl_loaded_at
from base
