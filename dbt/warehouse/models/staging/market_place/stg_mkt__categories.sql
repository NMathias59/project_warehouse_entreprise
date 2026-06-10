select
    id as category_id,
    name as category_name,
    slug as category_slug,
    position as category_position,
    parent_id as parent_category_id,
    created_at as created_at,
    deleted_at as deleted_at,
    updated_at as updated_at,
    description as category_description
from {{ source('marketplace', 'categories') }}
