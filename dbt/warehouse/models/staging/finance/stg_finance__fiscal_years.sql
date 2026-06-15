{{ config(tags=['staging', 'finance']) }}

select
    cast(id                                                                           as varchar)   as id_fiscal_year,
    cast(coalesce(toString(argMax(year, _airbyte_extracted_at)), '')                  as varchar)   as label,
    cast(argMax(start_date,  _airbyte_extracted_at)                                   as date)      as start_date,
    cast(argMax(end_date,    _airbyte_extracted_at)                                   as date)      as end_date,
    cast(argMax(status,      _airbyte_extracted_at) = 'closed'                        as boolean)   as is_closed,
    toDateTimeOrNull(toString(argMax(closed_at,   _airbyte_extracted_at)))                         as closed_at,
    cast(null                                                                         as Nullable(DateTime64(3))) as created_at,
    cast(max(_airbyte_extracted_at)                                                   as timestamp) as _etl_loaded_at
from {{ source('finance', 'fiscal_years') }}
where id is not null
group by id
