-- what is the Death-Cases ratio in each country each year?
select entity as country, round (sum(dwpm.deaths_weekavg)/sum(cwpm.cases_weekavg) , 5) as case_deaths_rat 
from covid_schema.cases_weekavg_per_million cwpm join covid_schema.deaths_weekavg_per_million dwpm using (entity, "day" )
where extract (year from "day") = '2021'
group by country , extract (year from "day")
having  
sum(cwpm.cases_weekavg) >0 -- undefined
and sum(dwpm.deaths_weekavg)>0
order by case_deaths_rat desc
