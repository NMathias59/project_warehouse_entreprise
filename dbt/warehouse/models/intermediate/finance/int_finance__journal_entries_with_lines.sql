{{ config(materialized='ephemeral', tags=['intermediate', 'finance']) }}

with journal_entries as (
    select * from {{ ref('stg_finance__journal_entries') }}
),

journal_lines as (
    select * from {{ ref('stg_finance__journal_lines') }}
),

accounts as (
    select * from {{ ref('stg_finance__accounts') }}
),

cost_centers as (
    select * from {{ ref('stg_finance__cost_centers') }}
)

select
    jl.id_journal_line,
    je.id_journal_entry,
    je.reference,
    je.journal_type,
    je.entry_date,
    je.description,
    je.status,
    je.period_id,
    jl.account_id,
    any(acc.account_number)                         as account_number,
    any(acc.label)                                  as account_label,
    any(acc.account_type)                           as account_type,
    jl.cost_center_id,
    any(cc.code)                                    as cost_center_code,
    any(cc.label)                                   as cost_center_label,
    jl.debit_amount,
    jl.credit_amount,
    jl.currency,
    jl.debit_amount - jl.credit_amount              as net_amount
from journal_entries as je
left join journal_lines as jl
    on jl.journal_entry_id = je.id_journal_entry
left join accounts as acc
    on acc.id_account = jl.account_id
left join cost_centers as cc
    on cc.id_cost_center = jl.cost_center_id
group by
    jl.id_journal_line,
    je.id_journal_entry,
    je.reference,
    je.journal_type,
    je.entry_date,
    je.description,
    je.status,
    je.period_id,
    jl.account_id,
    jl.cost_center_id,
    jl.debit_amount,
    jl.credit_amount,
    jl.currency
