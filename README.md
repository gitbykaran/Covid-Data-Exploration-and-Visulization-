# Analyzing COVID-19 Trends (2020-2023) Using SQL

### PROJECT OVERVIEW 
This data analysis project aims to analyze and derive insights from a comprehensive COVID-19 dataset spanning from 2020 to 2023 using SQL queries. The dataset includes information about confirmed cases, deaths, recoveries, testing rates, and other relevant metrics. The analysis focuses on understanding the trends, patterns, and key metrics related to the spread and impact of COVID-19 over this time period. SQL queries are utilized to extract, aggregate, and visualize the data to provide actionable insights for better understanding the progression of the pandemic.

### Data Sources 
Data Exploration is done using two Covid datasets - coviddeaths.csv & covidvaccinations.csv 

### Tools
- Excel - Data Cleaning
- SQL Server - Data Exploration

### Data Analysis with SQL
```sql
select * from [portfolio project]..covid_deaths
order by 3,4
```
Total Cases vs Total Deaths Analysis
``` sql
select location ,date,total_cases, total_deaths , (total_deaths/total_cases)*100 as deathpercentage
from [portfolio project]..covid_deaths
order by 1
```
Total Cases vs Total Deaths Analysis in United States
```sql
select location ,date,total_cases, total_deaths 
from [portfolio project]..covid_deaths
where location like '%states%'
order by 1
```
What % of population got Covid
```sql
select location ,date,population,total_cases,(total_cases/population)*100 as effectedpercentage 
from [portfolio project]..covid_deaths
order by 1 , 2
```
Countries with the highest Infection Rate vs Population 
```sql
select location , population , max(total_cases) as highestinfections , max((total_cases/population))*100 as percentpopulationaffected
from [portfolio project]..covid_deaths
group by location , population 
order by  4 desc
```
Countries with the highest deaths
```sql
select location , max(cast(total_deaths as int)) as highestdeaths 
from [portfolio project]..covid_deaths
where continent is not null
group by location 
order by  2 desc
```
No of deaths - Continent Analysis
```sql
select continent , max(cast(total_deaths as int)) as highestdeaths 
from [portfolio project]..covid_deaths
where continent is not null
group by continent
order by  2 desc
```
COMBINING DEATHS AND VACCINATIONS TABLE
```sql
select * from 
[portfolio project]..covid_deaths dea
join [portfolio project]..covid_vaccinations vac
on dea.location = vac.location and dea.date = vac.date 
```
TOTAL POPULATION VS VACCINATED POPULATION 
```sql
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations from 
[portfolio project]..covid_deaths dea
join [portfolio project]..covid_vaccinations vac
on dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null
order by 2,3
```
Sum of Total Vaccinations Partioned by Location 
```sql
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations ,
Sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date ) as vaccpeopleperloc from 
[portfolio project]..covid_deaths dea
join [portfolio project]..covid_vaccinations vac
on dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null
order by 2,3
```
Using CTE
```sql
with popvsvac(continent,location, date,population,new_vaccinations,vaccpeopleperloc) 
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations ,
Sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date ) as vaccpeopleperloc from 
[portfolio project]..covid_deaths dea
join [portfolio project]..covid_vaccinations vac
on dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null
)
select * , ( vaccpeopleperloc/population)*100 as perecentpopuvaccinated
from popvsvac
```
 USING TEMP TABLES
```sql
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
vaccpeopleperloc numeric
)
insert into #percentpopulationvaccinated 
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations ,
Sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date ) as vaccpeopleperloc from 
[portfolio project]..covid_deaths dea
join [portfolio project]..covid_vaccinations vac
on dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null
```
Retreiving Data from the Temp Table
```sql
select *,(vaccpeopleperloc/population)*100 as percpopuvaccinated from #percentpopulationvaccinated 
order by 2 
```
Creating VIEWS for future visualization 
```sql
create view popvsvac as 
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations ,
Sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date ) as vaccpeopleperloc from 
[portfolio project]..covid_deaths dea
join [portfolio project]..covid_vaccinations vac
on dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null
```
```sql
select * from popvsvac
```
# Data Visualization using Tableau 

## COVID 2020 - 2023 DASHBOARD 
![Opera Snapshot_2023-10-22_123742_public tableau com](https://github.com/gitbykaran/Covid-Data-Exploration-and-Visulization-/assets/147580511/6c13e84a-7228-48d5-abf0-6cac90a65df5)

[dashboard link](https://public.tableau.com/shared/B9Z9CFP68?:display_count=n&:origin=viz_share_link)










