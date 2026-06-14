{{ config(tags=['staging', 'sav']) }}

with source as (

    select * from {{ source('sav', 'tickets') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(reference,    _airbyte_extracted_at) as reference,
        argMax(title,        _airbyte_extracted_at) as title,
        argMax(description,  _airbyte_extracted_at) as description,
        argMax(status,       _airbyte_extracted_at) as status,
        argMax(priority,     _airbyte_extracted_at) as priority,
        argMax(ticket_type,  _airbyte_extracted_at) as ticket_type,
        argMax(channel,      _airbyte_extracted_at) as channel,
        argMax(customer_id,  _airbyte_extracted_at) as customer_id,
        argMax(order_id,     _airbyte_extracted_at) as order_id,
        argMax(product_id,   _airbyte_extracted_at) as product_id,
        argMax(assigned_to,  _airbyte_extracted_at) as assigned_to,
        argMax(resolved_at,  _airbyte_extracted_at) as resolved_at,
        argMax(closed_at,    _airbyte_extracted_at) as closed_at,
        argMax(created_at,   _airbyte_extracted_at) as created_at,
        argMax(updated_at,   _airbyte_extracted_at) as updated_at,
        max(_airbyte_extracted_at)                  as latest_extracted_at
    from source
    group by id

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
    toDateTimeOrNull(toString(updated_at))               as updated_at,
    cast(latest_extracted_at               as timestamp) as _etl_loaded_at
from deduped
