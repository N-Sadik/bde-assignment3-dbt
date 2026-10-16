-- Nightly price bands (A$). Fact rows map to a band with price >= min and < max.
select *
from (values
    (1, 'Budget (< $100)',          0::numeric,     100::numeric),
    (2, 'Mid ($100-199)',           100,            200),
    (3, 'Upper ($200-399)',         200,            400),
    (4, 'Premium ($400-999)',       400,            1000),
    (5, 'Luxury ($1000+)',          1000,           1e9)
) as t(price_band_id, price_band, price_min, price_max)
