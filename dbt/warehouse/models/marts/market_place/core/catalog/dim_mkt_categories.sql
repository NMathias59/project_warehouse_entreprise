{{
    config(
        materialized='table',
        tags=['mart', 'market_place', 'catalog'],
        order_by='(categorie_id)'
    )
}}

with categories as (

    select
        categorie_id,
        categorie_name,
        categorie_slug,
        categorie_description,
        categorie_parent_id,
        categorie_created_at,
        categorie_deleted_at
    from {{ ref('stg_mkt__categories') }}

)

select * from categories
