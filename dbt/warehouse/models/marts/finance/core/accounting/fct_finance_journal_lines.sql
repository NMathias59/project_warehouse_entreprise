{{ config(materialized='table', engine='MergeTree()', order_by='(id_journal_entry, id_journal_line)', tags=['marts','finance','fct']) }}
with source as (select * from {{ ref('int_finance__journal_entries_with_lines') }})
select * from source where status = 'posted'
