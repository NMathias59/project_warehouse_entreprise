select
    id as credit_note_id,
    amount as amount,
    number as number,
    reason as reason,
    pdf_url as pdf_url,
    order_id as order_id,
    issued_at as issued_at,
    return_id as return_id
from {{ source('marketplace', 'credit_notes') }}
