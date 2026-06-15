{{ config(materialized='incremental', unique_key='stock_id', incremental_strategy='append', tags=['mart','erp','core'],
           pre_hook=[ clickhouse_delete_existing_rows(ref('stg_erp__stock_levels'), 'id_stock_level', 'stock_id', 'updated_at', 7) ]) }}
{# clickhouse detected: 'merge' strategy may not be supported by the ClickHouse adapter.
   Using 'append' as a compatible incremental strategy. If updates must be applied, implement a
   delete+insert or dedup strategy appropriate for your adapter. #}

with sl as (
    select * from {{ ref('stg_erp__stock_levels') }}
),
cs as (
    select * from {{ ref('stg_erp__component_stock') }}
),

-- ClickHouse join_use_nulls=0 : FULL OUTER JOIN remplace NULL par '' pour les colonnes String,
-- effondrant toutes les lignes cs-only en stock_id=''. On contourne avec UNION + LEFT JOIN,
-- et if(sl.id_stock_level != '') pour distinguer les lignes matchées des non-matchées.
all_stock_keys as (
    select product_id,    warehouse_id from sl
    union distinct
    select component_id,  location_id  from cs
),

joined as (
    select
        if(sl.id_stock_level != '', sl.id_stock_level, cs.id_component_stock) as stock_id,
        k.product_id                                                            as product_id,
        k.warehouse_id                                                          as location_id,
        if(sl.id_stock_level != '', sl.quantity,    cs.quantity)               as quantity,
        if(sl.id_stock_level != '', sl.updated_at,  cs.updated_at)             as updated_at
    from all_stock_keys as k
    left join sl on sl.product_id  = k.product_id and sl.warehouse_id = k.warehouse_id
    left join cs on cs.component_id = k.product_id and cs.location_id  = k.warehouse_id
),

deduped as (
    select
        stock_id,
        product_id,
        location_id,
        quantity,
        updated_at,
        row_number() over (partition by stock_id order by updated_at desc) as rn
    from joined
)

select stock_id, product_id, location_id, quantity, updated_at
from deduped
where rn = 1

{% if is_incremental() %}
and updated_at > (select coalesce(max(updated_at), toDate('1970-01-01')) from {{ this }})
{% endif %}
