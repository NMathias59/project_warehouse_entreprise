{{ config(materialized='view', tags=['staging', 'qms']) }}

select
    id,
    argMax(nc_id,           _airbyte_extracted_at) as non_conformity_id,
    argMax(action_type,     _airbyte_extracted_at) as action_type,
    argMax(description,     _airbyte_extracted_at) as description,
    argMax(owner_ref,       _airbyte_extracted_at) as responsible_id,
    argMax(status,          _airbyte_extracted_at) as status,
    argMax(due_date,        _airbyte_extracted_at) as due_at,
    argMax(completed_date,  _airbyte_extracted_at) as implemented_at,
    argMax(created_at,      _airbyte_extracted_at) as created_at,
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('qms', 'corrective_actions') }}
where id is not null
group by id
