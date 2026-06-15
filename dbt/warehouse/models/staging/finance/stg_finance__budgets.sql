{{ config(tags=['staging', 'finance']) }}

select
    cast(id                                                                           as varchar)   as id_budget,
    cast(''                                                                           as varchar)   as label,
    cast(coalesce(argMax(fiscal_year_id, _airbyte_extracted_at), '')                  as varchar)   as fiscal_year_id,
    cast(''                                                                           as varchar)   as budget_type,
    cast(''                                                                           as varchar)   as status,
    cast(''                                                                           as varchar)   as validated_by,
    cast(null                                                                         as Nullable(DateTime64(3))) as validated_at,
    cast(null                                                                         as Nullable(DateTime64(3))) as created_at,
    cast(null                                                                         as Nullable(DateTime64(3))) as updated_at,
    cast(max(_airbyte_extracted_at)                                                   as timestamp) as _etl_loaded_at
from {{ source('finance', 'budgets') }}
where id is not null
group by id
