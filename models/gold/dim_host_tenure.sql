-- Host tenure bands: years hosting at the listing month (from host_since).
select *
from (values
    (0, 'Unknown',          null::int,  null::int),
    (1, '< 1 year',         0,          1),
    (2, '1-2 years',        1,          3),
    (3, '3-5 years',        3,          6),
    (4, '6+ years',         6,          100)
) as t(host_tenure_id, host_tenure_band, years_min, years_max)
