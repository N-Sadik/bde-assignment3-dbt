-- Suburb reference dimension (static), with its LGA.
select
    md5(suburb_name)    as suburb_id,
    suburb_name,
    lga_code,
    lga_name
from {{ ref('silver_suburb') }}
