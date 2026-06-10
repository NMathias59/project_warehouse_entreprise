select
    id as customer_address_id,
    city as city,
    label as label,
    street as street,
    last_name as last_name,
    created_at as created_at,
    deleted_at as deleted_at,
    first_name as first_name,
    is_default as is_default,
    customer_id as customer_id,
    postal_code as postal_code,
    country_code as country_code
from {{ source('marketplace', 'customer_addresses') }}
