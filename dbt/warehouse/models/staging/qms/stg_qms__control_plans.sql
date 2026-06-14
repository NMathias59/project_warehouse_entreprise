{{ config(tags=['staging', 'qms']) }}

with source as (

    select * from {{ source('qms', 'control_plans') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(product_id,      _airbyte_extracted_at) as product_id,
        argMax(process_name,    _airbyte_extracted_at) as process_name,
        argMax(version,         _airbyte_extracted_at) as version,
        argMax(status,          _airbyte_extracted_at) as status,
        argMax(responsible_id,  _airbyte_extracted_at) as responsible_id,
        argMax(effective_date,  _airbyte_extracted_at) as effective_date,
        argMax(created_at,      _airbyte_extracted_at) as created_at,
        argMax(updated_at,      _airbyte_extracted_at) as updated_at,
        max(_airbyte_extracted_at)                     as latest_extracted_at
    from source
    group by id

)

select
    cast(id                               as varchar)   as id_control_plan,
    cast(coalesce(product_id, '')         as varchar)   as product_id,
    cast(coalesce(process_name, '')       as varchar)   as process_name,
    cast(coalesce(version, '')            as varchar)   as version,
    cast(coalesce(status, '')             as varchar)   as status,
    cast(coalesce(responsible_id, '')     as varchar)   as responsible_id,
    cast(effective_date                   as date)      as effective_date,
    cast(created_at                       as timestamp) as created_at,
    toDateTimeOrNull(toString(updated_at))              as updated_at,
    cast(latest_extracted_at              as timestamp) as _etl_loaded_at
from deduped
