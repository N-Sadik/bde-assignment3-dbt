{% snapshot snapshot_room_type %}

{{
    config(
        target_schema='silver',
        unique_key='room_type_id',
        strategy='timestamp',
        updated_at='listing_month'
    )
}}

-- Room type lookup (Entire home/apt, Private room, Shared room, Hotel room).
select
    md5(room_type)              as room_type_id,
    room_type,
    max(listing_month)          as listing_month
from {{ ref('silver_listings') }}
where room_type is not null
group by room_type

{% endsnapshot %}
