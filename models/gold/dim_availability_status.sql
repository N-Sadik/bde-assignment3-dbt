-- Listing status: active means has_availability = 't'.
select *
from (values
    (1, true,  'Active'),
    (0, false, 'Inactive')
) as t(availability_status_id, has_availability, availability_status)
