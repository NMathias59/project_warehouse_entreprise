{{ config(tags=['staging', 'finance']) }}

with base as (

    select * from {{ ref('base_finance__accounts') }}

)

select
    cast(id                                              as varchar)   as id_account,
    cast(coalesce(account_number, '')                    as varchar)   as account_number,
    cast(coalesce(name,           '')                    as varchar)   as label,
    cast(coalesce(account_type,   '')                    as varchar)   as account_type,
    cast(''                                              as varchar)   as account_class,
    cast(coalesce(parent_id,      '')                    as varchar)   as parent_account_id,
    cast(false                                           as boolean)   as is_leaf,
    cast(coalesce(is_active,      false)                 as boolean)   as is_active,
    cast(created_at                                      as timestamp) as created_at,
    cast(null as Nullable(DateTime64(3)))                              as updated_at,
    cast(latest_extracted_at                as timestamp) as _etl_loaded_at
from base
