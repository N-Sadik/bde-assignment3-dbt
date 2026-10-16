-- SCD2 listing neighbourhood dimension (neighbourhood -> LGA).
select
    listing_neighbourhood_id,
    listing_neighbourhood,
    lga_code,
    lga_name,
    dbt_valid_from                                      as valid_from,
    coalesce(dbt_valid_to, '9999-12-31'::timestamp)     as valid_to,
    dbt_valid_to is null                                as is_current
from {{ ref('snapshot_listing_neighbourhood') }}
