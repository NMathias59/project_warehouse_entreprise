{{ config(materialized='view', tags=['intermediate', 'finance']) }}

select
    jl.id_journal_line                              as id_journal_line,
    je.id_journal_entry                             as id_journal_entry,
    je.reference                                    as reference,
    je.journal_type                                 as journal_type,
    je.entry_date                                   as entry_date,
    je.description                                  as description,
    je.status                                       as status,
    je.accounting_period_id                         as period_id,
    jl.account_id                                   as account_id,
    any(acc.account_number)                         as account_number,
    any(acc.label)                                  as account_label,
    any(acc.account_type)                           as account_type,
    jl.cost_center_id                               as cost_center_id,
    any(cc.code)                                    as cost_center_code,
    any(cc.label)                                   as cost_center_label,
    jl.debit_amount                                 as debit_amount,
    jl.credit_amount                                as credit_amount,
    jl.currency                                     as currency,
    jl.debit_amount - jl.credit_amount              as net_amount
from {{ ref('stg_finance__journal_entries') }} as je
left join {{ ref('stg_finance__journal_lines') }} as jl
    on jl.journal_entry_id = je.id_journal_entry
left join {{ ref('stg_finance__accounts') }} as acc
    on acc.id_account = jl.account_id
left join {{ ref('stg_finance__cost_centers') }} as cc
    on cc.id_cost_center = jl.cost_center_id
group by
    id_journal_line,
    id_journal_entry,
    reference,
    journal_type,
    entry_date,
    description,
    status,
    period_id,
    account_id,
    cost_center_id,
    debit_amount,
    credit_amount,
    currency
