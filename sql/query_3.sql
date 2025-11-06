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
