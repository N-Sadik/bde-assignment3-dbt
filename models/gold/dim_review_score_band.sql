-- Review score bands (review_scores_rating is 0-100). id 0 = no reviews yet.
select *
from (values
    (0, 'No rating',            null::numeric,  null::numeric),
    (1, 'Poor (< 80)',          0,              80),
    (2, 'Good (80-89)',         80,             90),
    (3, 'Very good (90-94)',    90,             95),
    (4, 'Excellent (95+)',      95,             101)
) as t(review_score_band_id, review_score_band, score_min, score_max)
