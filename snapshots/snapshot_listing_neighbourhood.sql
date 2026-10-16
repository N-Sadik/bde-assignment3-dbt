{% snapshot snapshot_listing_neighbourhood %}

{{
    config(
        target_schema='silver',
        unique_key='listing_neighbourhood_id',
        strategy='timestamp',
        updated_at='listing_month'
    )
}}

-- Listing neighbourhood -> LGA. listing_neighbourhood values are LGA names
-- (e.g. SYDNEY, INNER WEST), so they map straight onto silver_lga.
select
    md5(l.listing_neighbourhood)    as listing_neighbourhood_id,
    l.listing_neighbourhood,
    g.lga_code,
    g.lga_display_name              as lga_name,
    max(l.listing_month)            as listing_month
from {{ ref('silver_listings') }} l
left join {{ ref('silver_lga') }} g
    on l.listing_neighbourhood = g.lga_name
where l.listing_neighbourhood is not null
group by l.listing_neighbourhood, g.lga_code, g.lga_display_name

{% endsnapshot %}
