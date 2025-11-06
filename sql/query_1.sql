-- what countries had the highest different between the estimate and the actual death at 2021

select cedp.entity as country, avg(cedp.estimate_excess_deaths ) as avg_estimate,
avg(cedp.total_confirmed_deaths) as avg_deaths, avg(cedp.estimate_excess_deaths )-avg(cedp.total_confirmed_deaths ) as distance
from covid_schema.cumulative_exses_deaths_per_100000 cedp 
where cedp.total_confirmed_deaths > 0
and extract(year from cedp."day" )= '2021'
group by cedp.entity 
order by distance;


