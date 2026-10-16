{% snapshot snapshot_property_type %}

{{
    config(
        target_schema='silver',
        unique_key='property_type_id',
        strategy='timestamp',
        updated_at='listing_month'
    )
}}

-- Property type lookup (127 distinct values). The id is an md5 hash of the
-- name so the fact table can carry a stable key.
select
    md5(property_type)          as property_type_id,
    property_type,
    max(listing_month)          as listing_month
from {{ ref('silver_listings') }}
where property_type is not null
group by property_type

{% endsnapshot %}
