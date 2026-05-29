{{ config(tags=['staging', 'erp']) }}

select
    cast(id as varchar)                 as id_bank_transaction,
    cast(amount as Decimal(18, 2))     as amount,
    cast(balance as Decimal(18, 2))    as balance,
    cast(reference as varchar)         as reference,
    cast(value_date as timestamp)      as value_date,
    cast(description as varchar)       as description,
    cast(imported_at as timestamp)     as imported_at,
    cast(is_reconciled as boolean)     as is_reconciled,
    cast(bank_account_id as varchar)   as bank_account_id,
    cast(transaction_date as timestamp)as transaction_date
from {{ source('erp', 'bank_transactions') }}
where id is not null
