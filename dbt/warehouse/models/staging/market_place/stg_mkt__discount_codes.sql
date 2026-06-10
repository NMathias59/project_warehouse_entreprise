select
    id as discount_code_id,
    code as discount_code_code,
    type as discount_code_type,
    value as discount_code_value,
    max_uses as discount_code_max_uses,
    is_active as discount_code_is_active,
    min_order as discount_code_min_order,
    created_at as discount_code_created_at,
    expires_at as discount_code_expires_at,
    used_count as discount_code_used_count
from {{ source('marketplace', 'discount_codes') }}
