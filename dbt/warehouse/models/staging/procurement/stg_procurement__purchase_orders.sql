{{ config(tags=['staging', 'procurement']) }}

with source as (

    select * from {{ source('procurement', 'purchase_orders') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(reference,             _airbyte_extracted_at) as reference,
        argMax(supplier_id,           _airbyte_extracted_at) as supplier_id,
        argMax(contract_id,           _airbyte_extracted_at) as contract_id,
        argMax(status,                _airbyte_extracted_at) as status,
        argMax(buyer_id,              _airbyte_extracted_at) as buyer_id,
        argMax(delivery_address,      _airbyte_extracted_at) as delivery_address,
        argMax(currency,              _airbyte_extracted_at) as currency,
        argMax(total_amount,          _airbyte_extracted_at) as total_amount,
        argMax(expected_delivery_at,  _airbyte_extracted_at) as expected_delivery_at,
        argMax(sent_at,               _airbyte_extracted_at) as sent_at,
        argMax(created_at,            _airbyte_extracted_at) as created_at,
        argMax(updated_at,            _airbyte_extracted_at) as updated_at,
        max(_airbyte_extracted_at)                           as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                       as varchar)       as id_purchase_order,
    cast(coalesce(reference, '')                  as varchar)       as reference,
    cast(coalesce(supplier_id, '')                as varchar)       as supplier_id,
    cast(coalesce(contract_id, '')                as varchar)       as contract_id,
    cast(coalesce(status, '')                     as varchar)       as status,
    cast(coalesce(buyer_id, '')                   as varchar)       as buyer_id,
    cast(coalesce(delivery_address, '')           as varchar)       as delivery_address,
    cast(coalesce(currency, '')                   as varchar)       as currency,
    cast(coalesce(total_amount, 0)                as decimal(18,2)) as total_amount,
    toDateTimeOrNull(toString(expected_delivery_at))                as expected_delivery_at,
    toDateTimeOrNull(toString(sent_at))                             as sent_at,
    cast(created_at                               as timestamp)     as created_at,
    toDateTimeOrNull(toString(updated_at))                          as updated_at,
    cast(latest_extracted_at                      as timestamp)     as _etl_loaded_at
from deduped
