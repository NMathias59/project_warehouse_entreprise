{{ config(tags=['staging', 'finance']) }}

select
    cast(id                                              as varchar)   as id_account,
    cast(coalesce(argMax(account_number, _airbyte_extracted_at), '') as varchar) as account_number,
    cast(coalesce(argMax(name,           _airbyte_extracted_at), '') as varchar) as label,
    cast(coalesce(argMax(account_type,   _airbyte_extracted_at), '') as varchar) as account_type,
    cast(''                                              as varchar)   as account_class,
    cast(coalesce(argMax(parent_id,      _airbyte_extracted_at), '') as varchar) as parent_account_id,
    cast(false                                           as boolean)   as is_leaf,
    cast(coalesce(argMax(is_active,      _airbyte_extracted_at), false) as boolean) as is_active,
    cast(argMax(created_at,              _airbyte_extracted_at) as timestamp) as created_at,
    cast(null                            as Nullable(DateTime64(3)))   as updated_at,
    cast(max(_airbyte_extracted_at)      as timestamp)                 as _etl_loaded_at
from {{ source('finance', 'accounts') }}
where id is not null
group by id
