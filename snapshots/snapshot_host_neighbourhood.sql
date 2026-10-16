{% snapshot snapshot_host_neighbourhood %}

{{
    config(
        target_schema='silver',
        unique_key='host_neighbourhood_id',
        strategy='timestamp',
        updated_at='listing_month'
    )
}}

-- Host neighbourhood (a suburb) -> LGA via the suburb mapping. This is how
-- host_neighbourhood_lga for dm_host_neighbourhood is derived.
select
    md5(l.host_neighbourhood)       as host_neighbourhood_id,
    l.host_neighbourhood,
    s.lga_code                      as host_neighbourhood_lga_code,
    g.lga_display_name              as host_neighbourhood_lga,
    max(l.listing_month)            as listing_month
from {{ ref('silver_listings') }} l
left join {{ ref('silver_suburb') }} s
    on l.host_neighbourhood = s.suburb_name
left join {{ ref('silver_lga') }} g
    on s.lga_code = g.lga_code
where l.host_neighbourhood is not null
group by l.host_neighbourhood, s.lga_code, g.lga_display_name

{% endsnapshot %}
