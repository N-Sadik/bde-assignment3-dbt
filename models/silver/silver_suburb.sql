{{ config(materialized='table') }}

-- Suburb -> LGA mapping, enriched with the LGA code. Suburb names are unique
-- in the source file, so each suburb maps to exactly one LGA.
select
    upper(trim(s.suburb_name))      as suburb_name,
    upper(trim(s.lga_name))         as lga_name,
    l.lga_code
from {{ source('bronze', 'raw_lga_suburb') }} s
left join {{ ref('silver_lga') }} l
    on upper(trim(s.lga_name)) = l.lga_name
where nullif(trim(s.suburb_name), '') is not null
