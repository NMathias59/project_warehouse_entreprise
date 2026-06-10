select
    id as loyalty_point_id,
    customer_id as loyalty_customer_id,
    balance as balance,
    updated_at as loyalty_updated_at
from {{ source('marketplace', 'loyalty_points') }}
