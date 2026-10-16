{{ config(materialized='table') }}

-- LGA code <-> name. Name is upper-cased to match listing_neighbourhood and
-- the suburb file; the original spelling is kept for display.
select
    lga_code::int                   as lga_code,
    upper(trim(lga_name))           as lga_name,
    trim(lga_name)                  as lga_display_name
from {{ source('bronze', 'raw_lga_code') }}
where lga_code is not null
