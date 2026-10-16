{{ config(materialized='table') }}

{#
    Census G01 (person characteristics). 'LGA10050' -> 10050 so it joins to
    silver_lga.lga_code. The other 108 columns are counts: cast them all to
    integer by reading the column list from the bronze table.
#}
{%- set cols = adapter.get_columns_in_relation(source('bronze', 'raw_census_g01')) -%}

select
    replace(lga_code_2016, 'LGA', '')::int as lga_code
    {%- for col in cols if col.name | lower != 'lga_code_2016' %},
    nullif(trim({{ col.name }}), '')::int as {{ col.name | lower }}
    {%- endfor %}
from {{ source('bronze', 'raw_census_g01') }}
