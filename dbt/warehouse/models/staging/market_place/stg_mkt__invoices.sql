select
    id as invoice_id,
    number as invoice_number,
    order_id as invoice_order_id,
    issued_at as invoice_issued_at,
    due_at as invoice_due_at,
    total_ttc as invoice_total_ttc,
    pdf_url as invoice_pdf_url
from {{ source('marketplace', 'invoices') }}
