-- SCD2 host dimension built from snapshot_host.
-- valid_to of the current version is set to 9999-12-31 so range joins
-- (fact_month >= valid_from and fact_month < valid_to) need no null handling.
select
    dbt_scd_id                                          as host_version_id,
    host_id,
    host_name,
    host_since,
    host_is_superhost,
    host_neighbourhood,
    dbt_valid_from                                      as valid_from,
    coalesce(dbt_valid_to, '9999-12-31'::timestamp)     as valid_to,
    dbt_valid_to is null                                as is_current
from {{ ref('snapshot_host') }}
