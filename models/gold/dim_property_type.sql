-- SCD2 property type dimension built from snapshot_property_type.
select
    property_type_id,
    property_type,
    dbt_valid_from                                      as valid_from,
    coalesce(dbt_valid_to, '9999-12-31'::timestamp)     as valid_to,
    dbt_valid_to is null                                as is_current
from {{ ref('snapshot_property_type') }}
