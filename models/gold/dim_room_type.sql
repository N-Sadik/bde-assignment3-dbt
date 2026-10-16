-- SCD2 room type dimension built from snapshot_room_type.
select
    room_type_id,
    room_type,
    dbt_valid_from                                      as valid_from,
    coalesce(dbt_valid_to, '9999-12-31'::timestamp)     as valid_to,
    dbt_valid_to is null                                as is_current
from {{ ref('snapshot_room_type') }}
