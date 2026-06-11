{{
    config(
        materialized='incremental',
        unique_key='id_journal_entry',
        incremental_strategy='append',
        tags=['core', 'erp', 'fct', 'finance'],
        pre_hook=[
            "{{ clickhouse_delete_existing_rows(ref('stg_erp__journal_entries'), 'id_journal_entry', 'id_journal_entry', 'created_at', 7) }}"
        ]
    )
}}

with je as (

    select
        id_journal_entry,
        created_at,
        reference
    from {{ ref('stg_erp__journal_entries') }}

),

jel as (

    select
        id_journal_entry_line,
        journal_entry_id,
        account_number,
        debit,
        credit
    from {{ ref('stg_erp__journal_entry_lines') }}

)

select
    je.id_journal_entry as id_journal_entry,
    je.created_at,
    je.reference,
    jel.id_journal_entry_line as journal_entry_line_id,
    jel.account_number,
    jel.debit,
    jel.credit
from je
left join jel on je.id_journal_entry  = jel.journal_entry_id

{% if is_incremental() %}
where je.created_at > (select coalesce(max(created_at), '1970-01-01') from {{ this }})
{% endif %}