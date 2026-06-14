{{ config(tags=['staging', 'finance']) }}

with source as (

    select * from {{ source('finance', 'accounts') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(account_number,    _airbyte_extracted_at) as account_number,
        argMax(label,             _airbyte_extracted_at) as label,
        argMax(account_type,      _airbyte_extracted_at) as account_type,
        argMax(account_class,     _airbyte_extracted_at) as account_class,
        argMax(parent_account_id, _airbyte_extracted_at) as parent_account_id,
        argMax(is_leaf,           _airbyte_extracted_at) as is_leaf,
        argMax(is_active,         _airbyte_extracted_at) as is_active,
        argMax(created_at,        _airbyte_extracted_at) as created_at,
        argMax(updated_at,        _airbyte_extracted_at) as updated_at,
        max(_airbyte_extracted_at)                       as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                  as varchar)   as id_account,
    cast(coalesce(account_number, '')        as varchar)   as account_number,
    cast(coalesce(label, '')                 as varchar)   as label,
    cast(coalesce(account_type, '')          as varchar)   as account_type,
    cast(coalesce(account_class, '')         as varchar)   as account_class,
    cast(coalesce(parent_account_id, '')     as varchar)   as parent_account_id,
    cast(coalesce(is_leaf, false)            as boolean)   as is_leaf,
    cast(coalesce(is_active, false)          as boolean)   as is_active,
    cast(created_at                          as timestamp) as created_at,
    toDateTimeOrNull(toString(updated_at))                 as updated_at,
    cast(latest_extracted_at                 as timestamp) as _etl_loaded_at
from deduped
