{{ config(materialized='table', engine='MergeTree()', order_by='(warranty_type, status)', tags=['reports','sav','support']) }}
with warranties as (
    select warranty_type, status from {{ ref('fct_sav_warranties') }}
),
final as (
    select
        warranty_type,
        status,
        count(*)                                                    as nb_claims,
        countIf(status = 'approved')                                as nb_approved,
        countIf(status = 'rejected')                                as nb_rejected,
        countIf(status = 'open')                                    as nb_open,
        countIf(status = 'approved') / nullIf(count(*), 0)         as approval_rate
    from warranties
    group by warranty_type, status
)
select * from final
