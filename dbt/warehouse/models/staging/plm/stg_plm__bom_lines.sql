{{ config(tags=['staging', 'plm']) }}

with source as (

    select * from {{ source('plm', 'bom_lines') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(bom_id,               _airbyte_extracted_at) as bom_id,
        argMax(parent_component_id,  _airbyte_extracted_at) as parent_component_id,
        argMax(component_code,       _airbyte_extracted_at) as component_code,
        argMax(component_name,       _airbyte_extracted_at) as component_name,
        argMax(component_type,       _airbyte_extracted_at) as component_type,
        argMax(quantity,             _airbyte_extracted_at) as quantity,
        argMax(unit_of_measure,      _airbyte_extracted_at) as unit_of_measure,
        argMax(is_critical,          _airbyte_extracted_at) as is_critical,
        argMax(lead_time_days,       _airbyte_extracted_at) as lead_time_days,
        argMax(created_at,           _airbyte_extracted_at) as created_at,
        argMax(updated_at,           _airbyte_extracted_at) as updated_at,
        max(_airbyte_extracted_at)                          as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                   as varchar)       as id_bom_line,
    cast(coalesce(bom_id, '')                 as varchar)       as bom_id,
    cast(coalesce(parent_component_id, '')    as varchar)       as parent_component_id,
    cast(coalesce(component_code, '')         as varchar)       as component_code,
    cast(coalesce(component_name, '')         as varchar)       as component_name,
    cast(coalesce(component_type, '')         as varchar)       as component_type,
    cast(coalesce(quantity, 0)                as decimal(18,2)) as quantity,
    cast(coalesce(unit_of_measure, '')        as varchar)       as unit_of_measure,
    cast(coalesce(is_critical, false)         as boolean)       as is_critical,
    coalesce(lead_time_days, 0)                                 as lead_time_days,
    cast(created_at                           as timestamp)     as created_at,
    toDateTimeOrNull(toString(updated_at))                      as updated_at,
    cast(latest_extracted_at                  as timestamp)     as _etl_loaded_at
from deduped
