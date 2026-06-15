{{ config(tags=['staging', 'plm']) }}

with source as (

    select * from {{ source('plm', 'bom_lines') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(bom_id,        _airbyte_extracted_at) as bom_id,
        argMax(component_sku, _airbyte_extracted_at) as component_code,
        argMax(component_name, _airbyte_extracted_at) as component_name,
        argMax(quantity,      _airbyte_extracted_at) as quantity,
        argMax(unit,          _airbyte_extracted_at) as unit_of_measure,
        max(_airbyte_extracted_at)                   as latest_extracted_at
    from source
    group by id

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
    cast(latest_extracted_at                  as timestamp)     as _etl_loaded_at
from deduped
