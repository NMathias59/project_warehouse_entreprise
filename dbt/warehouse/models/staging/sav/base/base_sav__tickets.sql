{{ config(materialized='view', tags=['staging', 'sav']) }}

select
    id,
    argMax(ticket_number,   _airbyte_extracted_at) as reference,
    argMax(subject,         _airbyte_extracted_at) as title,
    argMax(description,     _airbyte_extracted_at) as description,
    argMax(status,          _airbyte_extracted_at) as status,
    argMax(priority,        _airbyte_extracted_at) as priority,
    argMax(category,        _airbyte_extracted_at) as ticket_type,
    argMax(channel,         _airbyte_extracted_at) as channel,
    argMax(customer_ref,    _airbyte_extracted_at) as customer_id,
    argMax(order_ref,       _airbyte_extracted_at) as order_id,
    argMax(product_sku,     _airbyte_extracted_at) as product_id,
    argMax(assigned_to_id,  _airbyte_extracted_at) as assigned_to,
    argMax(resolved_at,     _airbyte_extracted_at) as resolved_at,
    argMax(closed_at,       _airbyte_extracted_at) as closed_at,
    argMax(created_at,      _airbyte_extracted_at) as created_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('sav', 'tickets') }}
where id is not null
group by id
