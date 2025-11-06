-- what countries had the highest different between the estimate and the actual death at 2021

select cedp.entity as country, avg(cedp.estimate_excess_deaths ) as avg_estimate,
avg(cedp.total_confirmed_deaths) as avg_deaths, avg(cedp.estimate_excess_deaths )-avg(cedp.total_confirmed_deaths ) as distance
from covid_schema.cumulative_exses_deaths_per_100000 cedp 
where cedp.total_confirmed_deaths > 0
and extract(year from cedp."day" )= '2021'
group by cedp.entity 
order by distance;
**************************************************************************************************************************************************
--there is a corrolation between deaths and doses?
with corr_doses_death as 
(
	select dwpm.entity as country, corr(dopm.doses_week_avg, dwpm.deaths_weekavg ) cor_death_doses
	from covid_schema.deaths_weekavg_per_million dwpm join covid_schema."doses_weekAvg_per_million" dopm  
	on dwpm.entity = dopm.entity and dwpm."day" =dopm."Day" 
	group by country 
	order by cor_death_doses
)
select  count (*) as countries, 
concat(round ( 100 * count (case when cor_death_doses < -0.5 then 1 end  )/ count (*), 3), '%')  as "between_(-1)_(-0.5)", 
concat(round( 100 * count ( case when cor_death_doses between -0.5 and 0.5 then 1 end )/ count (*), 3),  '%') as "between_(-0.5)_(0.5)", 
concat(round( 100* count ( case when cor_death_doses >0.5 then 1 end)/count (*), 3), '%') as "between_(0.5)_(1)"
from corr_doses_death
**************************************************************************************************************************************************
--there is a diffrent corrolation between deaths and doses after 21 days?
with corr_doses_death as 
(
	select dwpm.entity as country, dwpm."day"  as date, dopm.doses_week_avg as doses_weekAvg_perM, dwpm.deaths_weekavg as death_weekAvg_perM,
	lag(dwpm.deaths_weekavg, 21) over (order by doses_week_avg) as death_weekAvg_perM_after_21_days
	from covid_schema.deaths_weekavg_per_million dwpm join covid_schema."doses_weekAvg_per_million" dopm  
	on dwpm.entity = dopm.entity and dwpm."day" =dopm."Day" 
),
 corr_doses_death_results as
(
	select country, corr(doses_weekAvg_perM, death_weekAvg_perM ) cor_death_doses,
	corr(doses_weekAvg_perM, death_weekAvg_perM_after_21_days ) cor_after21
	from corr_doses_death
	where death_weekAvg_perM_after_21_days is not null
	group by country
	order by cor_death_doses 
)
select  count (*) as countries, 
concat(round( 100*count (case when cor_after21 < -0.5 then 1 end  )/ count (*),1 ), '%') as "after_21_between_(-1)_(-0.5)", 
concat (round( 100* count ( case when cor_after21 between -0.5 and 0.5 then 1 end )/ count (*), 1), '%') as "after_21_between_(-0.5)_(0.5)", 
concat (round ( 100* count ( case when cor_after21> 0.5 then 1 end)/ count (*), 1) , '%') as "after_21_between_(0.5)_(1)" 
from corr_doses_death_results
************************************************************************************************************************************************
-- what is the Death-Cases ratio in each country each year?
select entity as country, round (sum(dwpm.deaths_weekavg)/sum(cwpm.cases_weekavg) , 5) as case_deaths_rat 
from covid_schema.cases_weekavg_per_million cwpm join covid_schema.deaths_weekavg_per_million dwpm using (entity, "day" )
where extract (year from "day") = '2021'
group by country , extract (year from "day")
having  
sum(cwpm.cases_weekavg) >0 -- undefined
and sum(dwpm.deaths_weekavg)>0
order by case_deaths_rat desc


