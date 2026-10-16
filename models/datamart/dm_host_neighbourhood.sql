/*
    KPIs per host_neighbourhood_lga and month.
    host_neighbourhood_lga: the host's suburb (dim_host, version valid that
    month) mapped to its LGA (dim_host_neighbourhood, version valid that month).
    Hosts with no / overseas neighbourhood are grouped as 'Unknown'.
*/

with base as (

    select
        coalesce(hn.host_neighbourhood_lga, 'Unknown')  as host_neighbourhood_lga,
        f.listing_month,
        f.host_id,
        f.is_active,
        f.estimated_revenue
    from {{ ref('fact_listings') }} f
    left join {{ ref('dim_host') }} h
        on  f.host_id = h.host_id
        and f.listing_month >= h.valid_from
        and f.listing_month <  h.valid_to
    left join {{ ref('dim_host_neighbourhood') }} hn
        on  md5(h.host_neighbourhood) = hn.host_neighbourhood_id
        and f.listing_month >= hn.valid_from
        and f.listing_month <  hn.valid_to

),

agg as (

    select
        host_neighbourhood_lga,
        listing_month,
        count(distinct host_id)                                 as distinct_hosts,
        sum(is_active)                                          as active_listings,
        sum(estimated_revenue) filter (where is_active = 1)     as total_estimated_revenue
    from base
    group by host_neighbourhood_lga, listing_month

)

select
    host_neighbourhood_lga,
    to_char(listing_month, 'MM/YYYY')                                   as month_year,
    listing_month,
    distinct_hosts,
    round(total_estimated_revenue / nullif(active_listings, 0), 2)      as avg_estimated_revenue_per_active_listing,
    round(total_estimated_revenue / nullif(distinct_hosts, 0), 2)       as estimated_revenue_per_host
from agg
order by host_neighbourhood_lga, listing_month
