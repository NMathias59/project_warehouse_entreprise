{{ config(tags=['staging', 'erp']) }}

with source as (
    select * from {{ source('erp', 'supplier_contracts') }}
)

select
    cast(id as varchar)              as id_supplier_contract,
    cast(supplier_id as varchar)     as supplier_id,
    cast(reference as varchar)       as reference,
    cast(currency as varchar)        as currency,
    cast(incoterm as varchar)        as incoterm,
    cast(valid_from as date)         as valid_from,
    if(valid_until is null, toDate('9999-12-31'), cast(valid_until as date)) as valid_until,
    cast(payment_days as int)        as payment_days,
    cast(created_at as timestamp)    as created_at
from source
where id is not null
