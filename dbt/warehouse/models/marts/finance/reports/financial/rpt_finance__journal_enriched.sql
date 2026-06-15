{{ config(materialized='table', engine='MergeTree()', order_by='(entry_date, account_number)', settings={'allow_nullable_key': 1}, tags=['reports','finance','financial']) }}

select
    jl.id_journal_line                                              as id_journal_line,
    jl.id_journal_entry                                             as id_journal_entry,
    jl.reference                                                    as reference,
    jl.journal_type                                                 as journal_type,
    jl.entry_date                                                   as entry_date,
    jl.description                                                  as description,
    jl.account_id                                                   as account_id,
    coalesce(a.account_number, jl.account_number)                   as account_number,
    coalesce(a.label, jl.account_label)                             as account_label,
    coalesce(a.account_type, jl.account_type)                       as account_type,
    jl.cost_center_id                                               as cost_center_id,
    coalesce(cc.code, jl.cost_center_code)                          as cost_center_code,
    coalesce(cc.label, jl.cost_center_label)                        as cost_center_label,
    jl.debit_amount                                                 as debit_amount,
    jl.credit_amount                                                as credit_amount,
    jl.net_amount                                                   as net_amount,
    jl.currency                                                     as currency
from {{ ref('fct_finance_journal_lines') }} as jl
left join {{ ref('dim_finance_accounts') }} as a
    on a.id_account = jl.account_id
left join {{ ref('dim_finance_cost_centers') }} as cc
    on cc.id_cost_center = jl.cost_center_id
