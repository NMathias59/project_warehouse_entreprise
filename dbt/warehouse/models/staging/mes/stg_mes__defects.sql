{{ config(tags=['staging', 'mes']) }}

with source as (

    select * from {{ source('mes', 'defects') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(inspection_id,      _airbyte_extracted_at) as operation_id,
        argMax(defect_code,        _airbyte_extracted_at) as defect_code,
        argMax(description,        _airbyte_extracted_at) as defect_description,
        argMax(severity,           _airbyte_extracted_at) as severity,
        argMax(created_at,         _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                        as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                     as varchar)       as id_defect,
    cast(''                                     as varchar)       as production_order_id,
    cast(coalesce(operation_id, '')             as varchar)       as operation_id,
    cast(''                                     as varchar)       as work_center_id,
    cast(coalesce(defect_code, '')              as varchar)       as defect_code,
    cast(coalesce(defect_description, '')       as varchar)       as defect_description,
    cast(coalesce(severity, '')                 as varchar)       as severity,
    cast(0                                      as decimal(18,2)) as quantity_defective,
    cast(false                                  as boolean)       as is_reworkable,
    cast(''                                     as varchar)       as detected_by,
    cast(created_at                             as timestamp)     as detected_at,
    cast(created_at                             as timestamp)     as created_at,
    cast(latest_extracted_at                    as timestamp)     as _etl_loaded_at
from deduped
