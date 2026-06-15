{{ config(tags=['staging', 'finance']) }}

with base as (

    select * from {{ ref('base_finance__budgets') }}

)

select
    cast(id                                    as varchar)   as id_budget,
    cast(''                                    as varchar)   as label,
    cast(coalesce(fiscal_year_id, '')          as varchar)   as fiscal_year_id,
    cast(''                                    as varchar)   as budget_type,
    cast(''                                    as varchar)   as status,
    cast(''                                    as varchar)   as validated_by,
    cast(null as Nullable(DateTime64(3)))                    as validated_at,
    cast(null as Nullable(DateTime64(3)))                    as created_at,
    cast(null as Nullable(DateTime64(3)))                    as updated_at,
    cast(latest_extracted_at                as timestamp) as _etl_loaded_at
from base
