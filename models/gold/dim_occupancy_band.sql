-- Occupancy bands on number of stays in the next 30 days (30 - availability_30).
select *
from (values
    (0, 'Not active',          null::int,  null::int),
    (1, 'Low (0-7 nights)',    0,          8),
    (2, 'Medium (8-15)',       8,          16),
    (3, 'High (16-23)',        16,         24),
    (4, 'Very high (24-30)',   24,         31)
) as t(occupancy_band_id, occupancy_band, stays_min, stays_max)
