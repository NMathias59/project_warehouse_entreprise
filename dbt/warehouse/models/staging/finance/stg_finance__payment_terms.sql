{{ config(tags=['staging', 'finance']) }}

with source as (

    select * from {{ source('finance', 'payment_terms') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(code,             _airbyte_extracted_at) as code,
        argMax(label,            _airbyte_extracted_at) as label,
        argMax(days_due,         _airbyte_extracted_at) as days_due,
        argMax(discount_days,    _airbyte_extracted_at) as discount_days,
        argMax(discount_percent, _airbyte_extracted_at) as discount_percent,
        argMax(is_active,        _airbyte_extracted_at) as is_active,
        argMax(created_at,       _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                      as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                  as varchar)       as id_payment_term,
    cast(coalesce(code, '')                  as varchar)       as code,
    cast(coalesce(label, '')                 as varchar)       as label,
    coalesce(days_due, 0)                                      as days_due,
    coalesce(discount_days, 0)                                 as discount_days,
    cast(coalesce(discount_percent, 0)       as decimal(18,2)) as discount_percent,
    cast(coalesce(is_active, false)          as boolean)       as is_active,
    cast(created_at                          as timestamp)     as created_at,
    cast(latest_extracted_at                 as timestamp)     as _etl_loaded_at
from deduped
