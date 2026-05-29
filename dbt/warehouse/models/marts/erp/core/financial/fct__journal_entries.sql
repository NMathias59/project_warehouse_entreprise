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
    select * from {{ ref('stg_erp__journal_entries') }}
),
jel as (
    select * from {{ ref('stg_erp__journal_entry_lines') }}
)

select
    je.id as id_journal_entry,
    je.posted_at,
    je.reference,
    jel.id as journal_entry_line_id,
    jel.account_id,
    jel.debit,
    jel.credit,
    jel.description
from je
left join jel on je.id = jel.journal_entry_id

{% if is_incremental() %}
where je.posted_at > (select coalesce(max(posted_at), '1970-01-01') from {{ this }})
{% endif %}