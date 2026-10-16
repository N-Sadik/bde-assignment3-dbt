{{ config(materialized='table') }}

/*
    Silver listings: typed, cleaned copy of bronze.raw_listings.

    Fixes applied
    - listing_month: taken from the source file name (MM_YYYY.csv), not from
      scraped_date. Some files contain scraped_date values outside their month
      (e.g. 07_2020.csv has rows dated 2020-09-05) and dates vary by several
      days inside a month. The file month is the reliable period, and it is
      used as the snapshot timestamp so all rows of a month share one date.
    - host_since: mixed d/m/yyyy formats parsed to DATE.
    - t/f flags converted to BOOLEAN.
    - Neighbourhood names trimmed and upper-cased so they join to the LGA and
      suburb reference tables; blank / OVERSEAS host neighbourhoods -> NULL.
*/

with src as (

    select * from {{ source('bronze', 'raw_listings') }}

),

typed as (

    select
        listing_id::bigint                                      as listing_id,
        scrape_id,  -- kept as text: id only, never used in calculations
        scraped_date::date                                      as scraped_date,
        -- '07_2020.csv' -> 2020-07-01
        make_date(
            split_part(replace(source_file, '.csv', ''), '_', 2)::int,
            split_part(source_file, '_', 1)::int,
            1
        )                                                       as listing_month_raw,
        source_file,

        host_id::bigint                                         as host_id,
        nullif(trim(host_name), '')                             as host_name,
        to_date(nullif(trim(host_since), ''), 'DD/MM/YYYY')     as host_since,
        case lower(trim(host_is_superhost))
            when 't' then true
            when 'f' then false
        end                                                     as host_is_superhost,
        case
            when upper(trim(host_neighbourhood)) in ('', 'OVERSEAS') then null
            else upper(trim(host_neighbourhood))
        end                                                     as host_neighbourhood,

        upper(trim(listing_neighbourhood))                      as listing_neighbourhood,
        trim(property_type)                                     as property_type,
        trim(room_type)                                         as room_type,
        accommodates::int                                       as accommodates,

        price::numeric(10, 2)                                   as price,
        lower(trim(has_availability)) = 't'                     as has_availability,
        availability_30::int                                    as availability_30,
        number_of_reviews::int                                  as number_of_reviews,
        review_scores_rating::numeric(5, 2)                     as review_scores_rating,
        review_scores_accuracy::numeric(5, 2)                   as review_scores_accuracy,
        review_scores_cleanliness::numeric(5, 2)                as review_scores_cleanliness,
        review_scores_checkin::numeric(5, 2)                    as review_scores_checkin,
        review_scores_communication::numeric(5, 2)              as review_scores_communication,
        review_scores_value::numeric(5, 2)                      as review_scores_value

    from src

)

select
    listing_id,
    scrape_id,
    scraped_date,
    -- first day of the file's month, as TIMESTAMP for the snapshot strategy
    listing_month_raw::timestamp                                as listing_month,
    source_file,
    host_id,
    host_name,
    host_since,
    host_is_superhost,
    host_neighbourhood,
    listing_neighbourhood,
    property_type,
    room_type,
    accommodates,
    price,
    has_availability,
    availability_30,
    number_of_reviews,
    review_scores_rating,
    review_scores_accuracy,
    review_scores_cleanliness,
    review_scores_checkin,
    review_scores_communication,
    review_scores_value
from typed
