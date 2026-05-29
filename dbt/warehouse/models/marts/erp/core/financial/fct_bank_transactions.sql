-- append_dedup doesn't exist on dbt-clickhouse → replace with append + pre_hook to remove duplicates before insertion
{{
    config(
        materialized='incremental',
        unique_key='id_bank_transaction',
        incremental_strategy='append',
        tags=['core', 'erp', 'fct', 'finance'],
        pre_hook=[
            "{{ clickhouse_delete_existing_rows(ref('stg_erp__bank_transactions'), 'id_bank_transaction', 'id_bank_transaction', 'transaction_date', 7) }}"
        ]
    )
}}

select id_bank_transaction,
       transaction_date,
       amount,
       balance,
       bank_account_id,
       reference,
       is_reconciled
from {{ ref('stg_erp__bank_transactions') }} {% if is_incremental() %}
where transaction_date
    > (select coalesce (max (transaction_date)
    , '1970-01-01') from {{ this }})
    {% endif %}