{{ config(tags=['staging', 'plm']) }}

with base as (

    select * from {{ ref('base_plm__bom_lines') }}

)

select
    cast(id                                   as varchar)       as id_bom_line,
    cast(coalesce(bom_id, '')                 as varchar)       as bom_id,
    cast(''                                   as varchar)       as parent_component_id,
    cast(coalesce(component_code, '')         as varchar)       as component_code,
    cast(coalesce(component_name, '')         as varchar)       as component_name,
    cast(''                                   as varchar)       as component_type,
    cast(coalesce(quantity, 0)                as decimal(18,2)) as quantity,
    cast(coalesce(unit_of_measure, '')        as varchar)       as unit_of_measure,
    cast(false                                as boolean)       as is_critical,
    0                                                           as lead_time_days,
    cast(null as Nullable(DateTime64(3)))                       as created_at,
    cast(null as Nullable(DateTime64(3)))                       as updated_at,
    cast(latest_extracted_at                as timestamp)     as _etl_loaded_at
from base
