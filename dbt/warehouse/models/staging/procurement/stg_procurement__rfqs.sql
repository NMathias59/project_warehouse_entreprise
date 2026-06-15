{{ config(tags=['staging', 'procurement']) }}

with base as (

    select * from {{ ref('base_procurement__rfqs') }}

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
    cast(latest_extracted_at                as timestamp) as _etl_loaded_at
from base
