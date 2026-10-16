-- SCD2 host neighbourhood dimension (host suburb -> host_neighbourhood_lga).
select
    host_neighbourhood_id,
    host_neighbourhood,
    host_neighbourhood_lga_code,
    host_neighbourhood_lga,
    dbt_valid_from                                      as valid_from,
    coalesce(dbt_valid_to, '9999-12-31'::timestamp)     as valid_to,
    dbt_valid_to is null                                as is_current
from {{ ref('snapshot_host_neighbourhood') }}
