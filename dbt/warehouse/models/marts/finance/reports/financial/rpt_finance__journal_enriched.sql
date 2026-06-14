{{ config(materialized='table', engine='MergeTree()', order_by='(entry_date, account_number)', tags=['reports','finance','financial']) }}
with journal as (
    select
        id_journal_line, journal_entry_id, reference, journal_type, entry_date,
        description, status, account_id, account_number, account_label, account_type,
        cost_center_id, cost_center_code, cost_center_label,
        debit_amount, credit_amount, net_amount, currency
    from {{ ref('fct_finance_journal_lines') }}
),
accounts as (
    select id_account, account_number, label as account_label, account_type
    from {{ ref('dim_finance_accounts') }}
),
cost_centers as (
    select id_cost_center, code as cc_code, label as cc_label
    from {{ ref('dim_finance_cost_centers') }}
),
final as (
    select
        j.id_journal_line,
        j.journal_entry_id,
        j.reference,
        j.journal_type,
        j.entry_date,
        j.description,
        j.account_id,
        coalesce(a.account_number, j.account_number)    as account_number,
        coalesce(a.account_label, j.account_label)      as account_label,
        coalesce(a.account_type, j.account_type)        as account_type,
        j.cost_center_id,
        coalesce(cc.cc_code, j.cost_center_code)        as cost_center_code,
        coalesce(cc.cc_label, j.cost_center_label)      as cost_center_label,
        j.debit_amount,
        j.credit_amount,
        j.net_amount,
        j.currency
    from journal as j
    left join accounts    as a  on a.id_account     = j.account_id
    left join cost_centers as cc on cc.id_cost_center = j.cost_center_id
)
select * from final
