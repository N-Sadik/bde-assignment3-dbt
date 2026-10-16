-- Census 2016 G02 reference table (medians and averages by LGA).
select * from {{ ref('silver_census_g02') }}
