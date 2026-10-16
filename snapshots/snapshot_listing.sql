{% snapshot snapshot_listing %}

{{
    config(
        target_schema='silver',
        unique_key='listing_id',
        strategy='timestamp',
        updated_at='listing_month'
    )
}}

-- Listing (property) entity: descriptive attributes that can change over time
-- (owner, type, capacity, location). Metrics such as price stay in the fact.
select distinct on (listing_id)
    listing_id,
    host_id,
    listing_neighbourhood,
    property_type,
    room_type,
    accommodates,
    listing_month
from {{ ref('silver_listings') }}
order by listing_id, listing_month desc, scraped_date desc

{% endsnapshot %}
