-- Guest capacity dimension with a band for coarser analysis.
select distinct
    accommodates                                as accommodates_id,
    accommodates,
    case
        when accommodates <= 2 then '1-2 guests'
        when accommodates <= 4 then '3-4 guests'
        when accommodates <= 6 then '5-6 guests'
        else '7+ guests'
    end                                         as accommodates_band
from {{ ref('silver_listings') }}
where accommodates is not null
