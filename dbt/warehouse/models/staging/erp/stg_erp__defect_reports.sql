{{ config(tags=['staging', 'erp']) }}

select
    cast(id as varchar) as id_defect_report,
    cast(created_at as timestamp) as created_at,
    cast(defect_type as varchar) as defect_type,
    cast(reported_at as timestamp) as reported_at,
    cast(resolved_at as timestamp) as resolved_at,
    cast(action_taken as varchar) as action_taken,
    cast(component_id as varchar) as component_id,
    cast(serial_number as varchar) as serial_number,
    cast(work_order_id as varchar) as work_order_id
from {{ source('erp', 'defect_reports') }}
where id is not null
