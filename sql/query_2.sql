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
concat(round ( 100 * sum (case when cor_death_doses < -0.5 then 1 else 0 end  )/ count (*), 1), '%')  as "between_(-1)_(-0.5)", 
concat(round( 100 * sum ( case when cor_death_doses between -0.5 and 0.5 then 1 else 0 end )/ count (*), 1),  '%') as "between_(-0.5)_(0.5)", 
concat(round( 100* sum ( case when cor_death_doses >0.5 then 1 else 0 end)/count (*), 1), '%') as "between_(0.5)_(1)"
from corr_doses_death
 
