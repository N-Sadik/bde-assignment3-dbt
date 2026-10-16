/*
    KPIs per listing_neighbourhood and month.
    SCD2: each fact row joins the dimension version valid in its month
    (listing_month >= valid_from and listing_month < valid_to), so e.g. the
    superhost rate uses each host's superhost status at that time.
*/

with base as (

    select
        coalesce(n.lga_name, n.listing_neighbourhood)   as listing_neighbourhood,
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
    join {{ ref('dim_listing_neighbourhood') }} n
        on  f.listing_neighbourhood_id = n.listing_neighbourhood_id
        and f.listing_month >= n.valid_from
        and f.listing_month <  n.valid_to
    left join {{ ref('dim_host') }} h
        on  f.host_id = h.host_id
        and f.listing_month >= h.valid_from
        and f.listing_month <  h.valid_to

),

agg as (

    select
        listing_neighbourhood,
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
    group by listing_neighbourhood, listing_month

)

select
    listing_neighbourhood,
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
window w as (partition by listing_neighbourhood order by listing_month)
order by listing_neighbourhood, listing_month
