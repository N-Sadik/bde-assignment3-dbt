/*
    Fact table: one row per listing per month. Holds only keys and metrics.

    Keys
    - listing_id / host_id / *_id: natural or hashed keys of the SCD2
      dimensions. Point-in-time attributes are resolved in the datamart with
      fact.listing_month >= dim.valid_from and fact.listing_month < dim.valid_to.
    - date_id, *_band_id, availability_status_id: static dimensions.

    Metrics (definitions from the brief)
    - is_active: 1 when has_availability = 't'
    - number_of_stays: 30 - availability_30, active listings only
    - estimated_revenue: number_of_stays * price, active listings only
*/

with listings as (

    -- guard against a listing appearing twice in the same monthly file
    select distinct on (listing_id, listing_month) *
    from {{ ref('silver_listings') }}
    order by listing_id, listing_month, scraped_date desc

),

measures as (

    select
        *,
        case when has_availability then 30 - availability_30 else 0 end     as stays,
        date_part('year', age(listing_month, host_since))::int              as host_years
    from listings

)

select
    -- keys
    m.listing_id,
    m.host_id,
    md5(m.property_type)                                    as property_type_id,
    md5(m.room_type)                                        as room_type_id,
    md5(m.listing_neighbourhood)                            as listing_neighbourhood_id,
    md5(m.host_neighbourhood)                               as host_neighbourhood_id,
    to_char(m.listing_month, 'YYYYMM')::int                 as date_id,
    m.listing_month,
    m.accommodates                                          as accommodates_id,
    pb.price_band_id,
    case when m.has_availability then 1 else 0 end          as availability_status_id,
    coalesce(rb.review_score_band_id, 0)                    as review_score_band_id,
    case when m.has_availability then ob.occupancy_band_id else 0 end as occupancy_band_id,
    coalesce(ht.host_tenure_id, 0)                          as host_tenure_id,

    -- metrics
    m.price,
    m.availability_30,
    case when m.has_availability then 1 else 0 end          as is_active,
    m.stays                                                 as number_of_stays,
    case when m.has_availability then m.stays * m.price else 0 end as estimated_revenue,
    m.number_of_reviews,
    m.review_scores_rating,
    m.review_scores_accuracy,
    m.review_scores_cleanliness,
    m.review_scores_checkin,
    m.review_scores_communication,
    m.review_scores_value

from measures m
left join {{ ref('dim_price_band') }} pb
    on m.price >= pb.price_min and m.price < pb.price_max
left join {{ ref('dim_review_score_band') }} rb
    on m.review_scores_rating >= rb.score_min and m.review_scores_rating < rb.score_max
left join {{ ref('dim_occupancy_band') }} ob
    on m.stays >= ob.stays_min and m.stays < ob.stays_max
left join {{ ref('dim_host_tenure') }} ht
    on m.host_years >= ht.years_min and m.host_years < ht.years_max
