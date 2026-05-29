{{
    config(
        materialized='incremental',
        unique_key='id_bank_reconciliation',
        incremental_strategy='append',
        tags=['core', 'erp', 'fct', 'finance'],
        pre_hook=[
            "{{ clickhouse_delete_existing_rows(ref('stg_erp__bank_reconciliations'), 'id_bank_reconciliation', 'id_bank_reconciliation', 'reconciled_at', 7) }}"
        ]
    )
}}

select
    id_bank_reconciliation,
    reconciled_at,
    reconciled_by,
    bank_account_id,
    bank_transaction_id,
    journal_entry_line_id
from {{ ref('stg_erp__bank_reconciliations') }}

{% if is_incremental() %}
where reconciled_at > (select coalesce(max(reconciled_at), '1970-01-01') from {{ this }})
{% endif %}