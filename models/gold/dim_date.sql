-- Month-grain date dimension covering the months present in the data.
select distinct
    to_char(listing_month, 'YYYYMM')::int       as date_id,
    listing_month                               as month_start,
    extract(year from listing_month)::int       as year,
    extract(month from listing_month)::int      as month,
    to_char(listing_month, 'Mon')               as month_name,
    to_char(listing_month, 'MM/YYYY')           as month_year,
    extract(quarter from listing_month)::int    as quarter
from {{ ref('silver_listings') }}
