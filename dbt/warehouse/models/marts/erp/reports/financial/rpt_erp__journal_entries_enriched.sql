{{ config(
    materialized='table',
    tags=['reports', 'erp', 'financial']
) }}

with journal_entries as (

    select
        id_journal_entry,
        created_at,
        reference,
        journal_entry_line_id,
        account_number,
        debit,
        credit
    from {{ ref('fct_journal_entries') }}

),

accounts as (

    select
        account_code,
        account_type
    from {{ ref('dim_accounts') }}

),

final as (

    select
        je.id_journal_entry,
        je.journal_entry_line_id,
        je.reference,
        je.account_number,
        acc.account_type,
        je.debit,
        je.credit,
        je.debit - je.credit                        as net_amount,
        toDate(je.created_at)                       as entry_date,
        toYear(toDate(je.created_at))               as entry_year,
        toYYYYMM(toDate(je.created_at))             as entry_month,
        toDayOfWeek(toDate(je.created_at))          as entry_day_of_week,
        je.created_at
    from journal_entries je
    left join accounts acc on je.account_number = acc.account_code

)

select * from final
