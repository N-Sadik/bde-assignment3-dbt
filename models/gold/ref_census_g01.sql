-- Census 2016 G01 reference table (person characteristics by LGA).
select * from {{ ref('silver_census_g01') }}
