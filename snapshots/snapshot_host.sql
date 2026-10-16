{% snapshot snapshot_host %}

{{
    config(
        target_schema='silver',
        unique_key='host_id',
        strategy='timestamp',
        updated_at='listing_month'
    )
}}

-- Host entity decomposed from listings. A host appears once per listing, so
-- keep one row per host: the most recent month, latest scrape within it.
-- updated_at = listing_month (file month) so every row of a month carries the
-- same timestamp and facts of that month match this version exactly.
select distinct on (host_id)
    host_id,
    host_name,
    host_since,
    host_is_superhost,
    host_neighbourhood,
    listing_month
from {{ ref('silver_listings') }}
where host_id is not null
order by host_id, listing_month desc, scraped_date desc

{% endsnapshot %}
