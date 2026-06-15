{{ config(tags=['staging', 'finance']) }}

with base as (

    select * from {{ ref('base_finance__fiscal_years') }}

)

select
    cast(id                                    as varchar)   as id_fiscal_year,
    cast(coalesce(toString(year), '')          as varchar)   as label,
    cast(start_date                            as date)      as start_date,
    cast(end_date                              as date)      as end_date,
    cast(status = 'closed'                     as boolean)   as is_closed,
    toDateTimeOrNull(toString(closed_at))                    as closed_at,
    cast(null as Nullable(DateTime64(3)))                    as created_at,
    cast(latest_extracted_at                as timestamp) as _etl_loaded_at
from base
