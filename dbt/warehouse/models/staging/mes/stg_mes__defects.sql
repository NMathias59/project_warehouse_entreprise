{{ config(tags=['staging', 'mes']) }}

with source as (

    select * from {{ source('mes', 'defects') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(production_order_id, _airbyte_extracted_at) as production_order_id,
        argMax(operation_id,        _airbyte_extracted_at) as operation_id,
        argMax(work_center_id,      _airbyte_extracted_at) as work_center_id,
        argMax(defect_code,         _airbyte_extracted_at) as defect_code,
        argMax(defect_description,  _airbyte_extracted_at) as defect_description,
        argMax(severity,            _airbyte_extracted_at) as severity,
        argMax(quantity_defective,  _airbyte_extracted_at) as quantity_defective,
        argMax(is_reworkable,       _airbyte_extracted_at) as is_reworkable,
        argMax(detected_by,         _airbyte_extracted_at) as detected_by,
        argMax(detected_at,         _airbyte_extracted_at) as detected_at,
        argMax(created_at,          _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                         as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                     as varchar)       as id_defect,
    cast(coalesce(production_order_id, '')      as varchar)       as production_order_id,
    cast(coalesce(operation_id, '')             as varchar)       as operation_id,
    cast(coalesce(work_center_id, '')           as varchar)       as work_center_id,
    cast(coalesce(defect_code, '')              as varchar)       as defect_code,
    cast(coalesce(defect_description, '')       as varchar)       as defect_description,
    cast(coalesce(severity, '')                 as varchar)       as severity,
    cast(coalesce(quantity_defective, 0)        as decimal(18,2)) as quantity_defective,
    cast(coalesce(is_reworkable, false)         as boolean)       as is_reworkable,
    cast(coalesce(detected_by, '')              as varchar)       as detected_by,
    cast(detected_at                            as timestamp)     as detected_at,
    cast(created_at                             as timestamp)     as created_at,
    cast(latest_extracted_at                    as timestamp)     as _etl_loaded_at
from deduped
