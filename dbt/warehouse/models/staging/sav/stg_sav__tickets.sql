{{ config(tags=['staging', 'sav']) }}

with base as (

    select * from {{ ref('base_sav__tickets') }}

)

select
    cast(id                                as varchar)   as id_ticket,
    cast(coalesce(reference, '')           as varchar)   as reference,
    cast(coalesce(title, '')               as varchar)   as title,
    cast(coalesce(description, '')         as varchar)   as description,
    cast(coalesce(status, '')              as varchar)   as status,
    cast(coalesce(priority, '')            as varchar)   as priority,
    cast(coalesce(ticket_type, '')         as varchar)   as ticket_type,
    cast(coalesce(channel, '')             as varchar)   as channel,
    cast(coalesce(customer_id, '')         as varchar)   as customer_id,
    cast(coalesce(order_id, '')            as varchar)   as order_id,
    cast(coalesce(product_id, '')          as varchar)   as product_id,
    cast(coalesce(assigned_to, '')         as varchar)   as assigned_to,
    toDateTimeOrNull(toString(resolved_at))              as resolved_at,
    toDateTimeOrNull(toString(closed_at))                as closed_at,
    cast(created_at                        as timestamp) as created_at,
    cast(null as Nullable(DateTime64(3)))                as updated_at,
    cast(latest_extracted_at                as timestamp) as _etl_loaded_at
from base
