select * from [portfolio project]..covid_deaths
order by 3,4


-- selecting data for anlaysis

select location,date,total_cases,new_cases,total_deaths,population
from [portfolio project]..covid_deaths
order by 1 ,2

-- Total Cases vs Total Deaths Analysis

select location ,date,total_cases, total_deaths , (total_deaths/total_cases)*100 as deathpercentage
from [portfolio project]..covid_deaths
order by 1

-- Total Cases vs Total Deaths Analysis in United States

select location ,date,total_cases, total_deaths 
from [portfolio project]..covid_deaths
where location like '%states%'
order by 1

-- Total Cases vs Population 
-- What % of population got Covid

select location ,date,population,total_cases,(total_cases/population)*100 as effectedpercentage 
from [portfolio project]..covid_deaths
order by 1 , 2

-- What % of population got Covid in United States 

select location ,date,population,total_cases,(total_cases/population)*100 as effectedpercentage 
from [portfolio project]..covid_deaths
where location like '%states%'
order by 1 , 2

-- Countries with the highest Infection Rate vs Population 

select location , population , max(total_cases) as highestinfections , max((total_cases/population))*100 as percentpopulationaffected
from [portfolio project]..covid_deaths
group by location , population 
order by  4 desc

-- Countries with the highest deaths

select location , max(cast(total_deaths as int)) as highestdeaths 
from [portfolio project]..covid_deaths
where continent is not null
group by location 
order by  2 desc

-- No of deaths - Continent Analysis

select continent , max(cast(total_deaths as int)) as highestdeaths 
from [portfolio project]..covid_deaths
where continent is not null
group by continent
order by  2 desc

--- GLOBAL NUMBERS

select date, sum(new_cases) as newcases, sum(new_deaths) as newdeaths,(sum(new_deaths)/sum(new_cases)*100) as globaldeathpercentage
from [portfolio project]..covid_deaths
where continent is not null 
group by date
order by 1

select sum(new_cases) as newcases, sum(new_deaths) as newdeaths , (sum(new_deaths)/sum(new_cases))*100 as globaldeathpercentage
from [portfolio project]..covid_deaths
where continent is not null 
order by 1


--- COVID VACCINATIONS TABLE

select * from [portfolio project]..covid_vaccinations

--- COMBINING DEATHS AND VACCINATIONS TABLE

select * from 
[portfolio project]..covid_deaths dea
join [portfolio project]..covid_vaccinations vac
on dea.location = vac.location and dea.date = vac.date 

--- TOTAL POPULATION VS VACCINATED POPULATION 

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations from 
[portfolio project]..covid_deaths dea
join [portfolio project]..covid_vaccinations vac
on dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null
order by 2,3

--- Sum of Total Vaccinations Partioned by Location 

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations ,
Sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date ) as vaccpeopleperloc from 
[portfolio project]..covid_deaths dea
join [portfolio project]..covid_vaccinations vac
on dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null
order by 2,3

--- Using CTE

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


--- USING TEMP TABLES

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

--- Retreiving Data from the Temp Table

select *,(vaccpeopleperloc/population)*100 as percpopuvaccinated from #percentpopulationvaccinated 
order by 2 

--- Creating VIEWS for future visualization 

create view popvsvac as 
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations ,
Sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date ) as vaccpeopleperloc from 
[portfolio project]..covid_deaths dea
join [portfolio project]..covid_vaccinations vac
on dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null

select * from popvsvac