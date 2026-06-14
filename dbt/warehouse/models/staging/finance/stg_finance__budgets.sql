{{ config(tags=['staging', 'finance']) }}

with source as (

    select * from {{ source('finance', 'budgets') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(label,           _airbyte_extracted_at) as label,
        argMax(fiscal_year_id,  _airbyte_extracted_at) as fiscal_year_id,
        argMax(budget_type,     _airbyte_extracted_at) as budget_type,
        argMax(status,          _airbyte_extracted_at) as status,
        argMax(validated_by,    _airbyte_extracted_at) as validated_by,
        argMax(validated_at,    _airbyte_extracted_at) as validated_at,
        argMax(created_at,      _airbyte_extracted_at) as created_at,
        argMax(updated_at,      _airbyte_extracted_at) as updated_at,
        max(_airbyte_extracted_at)                     as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                  as varchar)   as id_budget,
    cast(coalesce(label, '')                 as varchar)   as label,
    cast(coalesce(fiscal_year_id, '')        as varchar)   as fiscal_year_id,
    cast(coalesce(budget_type, '')           as varchar)   as budget_type,
    cast(coalesce(status, '')                as varchar)   as status,
    cast(coalesce(validated_by, '')          as varchar)   as validated_by,
    toDateTimeOrNull(toString(validated_at))               as validated_at,
    cast(created_at                          as timestamp) as created_at,
    toDateTimeOrNull(toString(updated_at))                 as updated_at,
    cast(latest_extracted_at                 as timestamp) as _etl_loaded_at
from deduped
