{{ config(tags=['staging', 'erp']) }}

select
    cast(id as varchar)                      as id_bank_reconciliation,
    cast(reconciled_at as timestamp)         as reconciled_at,
    cast(reconciled_by as varchar)           as reconciled_by,
    cast(bank_account_id as varchar)         as bank_account_id,
    cast(bank_transaction_id as varchar)     as bank_transaction_id,
    cast(journal_entry_line_id as varchar)   as journal_entry_line_id
from {{ source('erp', 'bank_reconciliations') }}
where id is not null
