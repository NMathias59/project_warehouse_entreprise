{{ config(tags=['staging', 'finance']) }}

with source as (

    select * from {{ source('finance', 'fiscal_years') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(label,       _airbyte_extracted_at) as label,
        argMax(start_date,  _airbyte_extracted_at) as start_date,
        argMax(end_date,    _airbyte_extracted_at) as end_date,
        argMax(is_closed,   _airbyte_extracted_at) as is_closed,
        argMax(closed_at,   _airbyte_extracted_at) as closed_at,
        argMax(created_at,  _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                 as latest_extracted_at
    from source
    group by id

)

select
    cast(id                               as varchar)   as id_fiscal_year,
    cast(coalesce(label, '')              as varchar)   as label,
    cast(start_date                       as date)      as start_date,
    cast(end_date                         as date)      as end_date,
    cast(coalesce(is_closed, false)       as boolean)   as is_closed,
    toDateTimeOrNull(toString(closed_at))               as closed_at,
    cast(created_at                       as timestamp) as created_at,
    cast(latest_extracted_at              as timestamp) as _etl_loaded_at
from deduped
