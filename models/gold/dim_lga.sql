-- LGA reference dimension (static: LGA boundaries do not change in the period).
select
    lga_code,
    lga_display_name    as lga_name,
    lga_name            as lga_name_upper
from {{ ref('silver_lga') }}
