{{ config(tags=['staging', 'erp']) }}


select
    cast(id as varchar)              as id_bom_header,
    cast(notes as varchar)           as notes,
    cast(version as varchar)         as version,
    cast(created_at as timestamp)    as created_at,
    cast(is_current as boolean)      as is_current,
    cast(pc_model_id as varchar)     as pc_model_id
from {{ source('erp', 'bom_headers') }}
where id is not null
