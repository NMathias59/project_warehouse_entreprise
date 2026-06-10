select
    id as discount_code_usage_id,
    used_at as used_at,
    order_id as order_id,
    discount_amount as discount_amount,
    discount_code_id as discount_code_id
from {{ source('marketplace', 'discount_code_usages') }}
