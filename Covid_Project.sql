select * from CovidDeaths$
order by 3,4


select * from CovidVaccinations$
order by 3,4


select location,date,total_cases, new_cases, total_deaths, population
from CovidDeaths$
order by 1,2

-- India Total Cases vs PoPulation

select location,date,population,total_cases, total_deaths, (total_cases
/population)*100 as Percentage_Population_Infected
from CovidDeaths$
where location like '%india%'
order by 1,2


-- India Total Cases vs Total Deaths

select location,date,total_cases, total_deaths, (total_deaths
/total_cases)*100 as DeathPercentage
from CovidDeaths$
where location like '%india%'
order by 1,2



-- Countries with Highest Infection Rate compared to Population

select location, population,max(total_cases) as Highest_Infection_Count, max((total_cases/population))*100 as Percentage_PoPulation_Infected
from CovidDeaths$
Group by location, population
order by Percentage_PoPulation_Infected desc



--Counties with Highest Death Count

select location , max(cast(total_deaths as int)) as Death_Count
from CovidDeaths$
where continent is not null
group by location
order by Death_Count desc

-- Highest Death Countby Continent

select continent , max(cast(total_deaths as int)) as Death_Count
from CovidDeaths$
where continent is not null
group by continent
order by Death_Count desc


-- Global Highest Death Count

select sum(new_cases)as TotalCases, sum(cast(new_deaths as int)) as TotalDeath,
(sum(cast(new_deaths as int))/sum(new_cases))*100 as Death_Percentage
from CovidDeaths$
where continent is not null
order by 1,2


--Joining CovidDeaths and CovidVaccinations Table

select * from CovidDeaths$ cd join CovidVaccinations$ cv
on cd.location=cv.location
and cd.date=cv.date


-- Total Population vs Vaccinations

select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location,cd.date)as peoplevaccinated
from CovidDeaths$ cd join CovidVaccinations$ cv
on cd.location=cv.location
and cd.date=cv.date
where cd.continent is not null
order by 2,3

--CTE 

with POPvsVACC (continent,location,date,population,new_vaccinations,people_vaccination) as
(
select cd.continent, cd.location, cd.date,
cd.population, cv.new_vaccinations, sum(cast(cv.new_vaccinations as int))
over (partition by cd.location order by cd.location,cd.date)as people_vaccinated
from CovidDeaths$ cd join CovidVaccinations$ cv
on cd.location=cv.location
and cd.date=cv.date
where cd.continent is not null
)

select *,(people_vaccination/population)*100
as Population_VACC from POPvsVACC



--TEMP table

drop table if exists #percent_populationvaccinated

create table #percent_populationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
peoplevaccination numeric
)


insert into #percent_populationvaccinated
select cd.continent, cd.location, cd.date,cd.population, cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int))over (partition by cd.location order by cd.location,cd.date)as people_vaccinated
from CovidDeaths$ cd join CovidVaccinations$ cv
on cd.location=cv.location
and cd.date=cv.date
where cd.continent is not null


select *,(peoplevaccination/population)*100
as Population_VACC from #percent_populationvaccinated



--Creating View 

create view percent_populationvaccinated as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int))over (partition by cd.location order by cd.location,cd.date)as people_vaccinated
from CovidDeaths$ cd join CovidVaccinations$ cv
on cd.location=cv.location
and cd.date=cv.date
where cd.continent is not null

select * from percent_populationvaccinated



-- Queries used for visulaization


--1

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths$
where continent is not null 
order by 1,2

--2

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidDeaths$
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths$
Group by Location, Population
order by PercentPopulationInfected desc


-- 4


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths$
Group by Location, Population, date
order by PercentPopulationInfected desc

 
