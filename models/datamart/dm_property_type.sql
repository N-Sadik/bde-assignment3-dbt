/*
    KPIs per property_type, room_type, accommodates and month.
    property_type / room_type come from their SCD2 dimensions and accommodates
    from the listing version valid in that month (dim_listing).
*/

with base as (

    select
        pt.property_type,
        rt.room_type,
        l.accommodates,
        f.listing_month,
        f.listing_id,
        f.host_id,
        f.is_active,
        f.price,
        f.review_scores_rating,
        f.number_of_stays,
        f.estimated_revenue,
        h.host_is_superhost
    from {{ ref('fact_listings') }} f
    join {{ ref('dim_property_type') }} pt
        on  f.property_type_id = pt.property_type_id
        and f.listing_month >= pt.valid_from
        and f.listing_month <  pt.valid_to
    join {{ ref('dim_room_type') }} rt
        on  f.room_type_id = rt.room_type_id
        and f.listing_month >= rt.valid_from
        and f.listing_month <  rt.valid_to
    join {{ ref('dim_listing') }} l
        on  f.listing_id = l.listing_id
        and f.listing_month >= l.valid_from
        and f.listing_month <  l.valid_to
    left join {{ ref('dim_host') }} h
        on  f.host_id = h.host_id
        and f.listing_month >= h.valid_from
        and f.listing_month <  h.valid_to

),

agg as (

    select
        property_type,
        room_type,
        accommodates,
        listing_month,
        count(*)                                                        as total_listings,
        sum(is_active)                                                  as active_listings,
        count(*) - sum(is_active)                                       as inactive_listings,
        min(price) filter (where is_active = 1)                         as min_price,
        max(price) filter (where is_active = 1)                         as max_price,
        percentile_cont(0.5) within group (order by price)
            filter (where is_active = 1)                                as median_price,
        avg(price) filter (where is_active = 1)                         as avg_price,
        count(distinct host_id)                                         as distinct_hosts,
        count(distinct host_id) filter (where host_is_superhost)        as distinct_superhosts,
        avg(review_scores_rating) filter (where is_active = 1)          as avg_review_scores_rating,
        sum(number_of_stays) filter (where is_active = 1)               as total_stays,
        sum(estimated_revenue) filter (where is_active = 1)             as total_estimated_revenue
    from base
    group by property_type, room_type, accommodates, listing_month

)

select
    property_type,
    room_type,
    accommodates,
    to_char(listing_month, 'MM/YYYY')                                   as month_year,
    listing_month,
    round(100.0 * active_listings / nullif(total_listings, 0), 2)       as active_listings_rate,
    min_price,
    max_price,
    round(median_price::numeric, 2)                                     as median_price,
    round(avg_price, 2)                                                 as avg_price,
    distinct_hosts,
    round(100.0 * distinct_superhosts / nullif(distinct_hosts, 0), 2)   as superhost_rate,
    round(avg_review_scores_rating, 2)                                  as avg_review_scores_rating,
    round(100.0 * (active_listings - lag(active_listings) over w)
          / nullif(lag(active_listings) over w, 0), 2)                  as pct_change_active_listings,
    round(100.0 * (inactive_listings - lag(inactive_listings) over w)
          / nullif(lag(inactive_listings) over w, 0), 2)                as pct_change_inactive_listings,
    total_stays,
    round(total_estimated_revenue / nullif(active_listings, 0), 2)      as avg_estimated_revenue_per_active_listing
from agg
window w as (partition by property_type, room_type, accommodates order by listing_month)
order by property_type, room_type, accommodates, listing_month
