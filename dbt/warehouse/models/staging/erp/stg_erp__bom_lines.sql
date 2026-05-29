{{ config(tags=['staging', 'erp']) }}

select
    cast(id as varchar)               as id_bom_line,
    cast(notes as varchar)            as notes,
    cast(position as int)             as position,
    cast(quantity as Decimal(18, 2))  as quantity,
    cast(component_id as varchar)     as component_id,
    cast(bom_header_id as varchar)    as bom_header_id
from {{ source('erp', 'bom_lines') }}
where id is not null
