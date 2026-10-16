-- SCD2 listing (property) dimension built from snapshot_listing.
select
    dbt_scd_id                                          as listing_version_id,
    listing_id,
    host_id,
    listing_neighbourhood,
    property_type,
    room_type,
    accommodates,
    dbt_valid_from                                      as valid_from,
    coalesce(dbt_valid_to, '9999-12-31'::timestamp)     as valid_to,
    dbt_valid_to is null                                as is_current
from {{ ref('snapshot_listing') }}
