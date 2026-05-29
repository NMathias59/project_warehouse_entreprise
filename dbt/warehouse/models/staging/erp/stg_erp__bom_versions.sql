{{ config(tags=['staging', 'erp']) }}

select
    cast(id as varchar)             as id_bom_version,
    cast(snapshot as varchar)       as snapshot,
    cast(changelog as varchar)      as changelog,
    cast(created_at as timestamp)   as created_at,
    cast(created_by as varchar)     as created_by,
    cast(version_label as varchar)  as version_label
from {{ source('erp', 'bom_versions') }}
where id is not null
