{{ config(tags=['staging', 'procurement']) }}

with base as (

    select * from {{ ref('base_procurement__rfq_responses') }}

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
    cast(latest_extracted_at                as timestamp)     as _etl_loaded_at
from base
