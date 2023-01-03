select location,date,total_cases,new_cases,total_deaths, population_density
from Covid_Death
order by 3,4

---Looking for tota case vs total deaths
---Shows likelihood of death in our coutry if contacted with Covid
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercent
from Covid_Death
where location like '%India%'
order by 1,2

---Looking at total cases vs Population
---Shows what percent got covid
select location,date,total_cases,population_density, (total_deaths/population_density)*100 as percentofpopulationinfected
from Covid_Death
where location like '%India%'
order by 1,2

---Looking at countries with highest infection ratecompared to population
select location,max(total_cases) as highestinfectioncount,population_density, max((total_deaths/population_density)*100) as percentofpopulationinfected
from Covid_Death
--where location like '%India%'
group by location,population_density
order by 1,2

--Showing countries with highest death count per population
select location,max(total_cases) as highestinfectioncount,population_density, max((total_deaths/population_density)*100) as percentofpopulationinfected
from Covid_Death
--where location like '%India%'
group by location,population_density
order by percentofpopulationinfected desc

select location,Max(Total_deaths) as totaldeathcount
from [Portfolio Project].[dbo].[Coviddeaths]
--where location like '%India%'
where continent is not NULL
group by location
order by totaldeathcount desc

--LETS BREAK THINGS DOWN BY CONTINENT
select location,Max(Total_deaths) as totaldeathcount
from [Portfolio Project].[dbo].[Coviddeaths]
--where location like '%India%'
where continent is NULL
group by location
order by totaldeathcount desc

--showing continents with highest death count
select location,Max(Total_deaths) as totaldeathcount
from [Portfolio Project].[dbo].[Coviddeaths]
--where location like '%India%'
where continent is NULL
group by location
order by totaldeathcount desc

--Global numbers
select date,sum(new_cases),sum(cast(new_deaths AS int)), sum(cast(new_deaths AS int) )/sum(new_cases) * 100 as deathpercent
from [Portfolio Project].[dbo].[Coviddeaths]
where continent is not null
group by date
order by 1,2

--JOIN
--Comparing Total population vs vaccinations
select *
from [Portfolio Project].[dbo].[Coviddeaths] dea
join [Portfolio Project].[dbo].[Covid_Vacc] vac
on dea.location = vac.location and dea.date = vac.date

select dea.location, dea.continent, dea.date, dea.population_density, vac.new_vaccinations,
sum(cast(vac.new_vaccinations AS int)) OVER (partition by dea.location order by dea.location,dea.date ) AS RollingPplVaccinated
from [Portfolio Project].[dbo].[Coviddeaths] dea
join [Portfolio Project].[dbo].[Covid_Vacc] vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

--Use CTE
With PopvsVac (continent,location,date,population_desity,new_vaccinations,RollingPplVaccinated)
As
(
select dea.location, dea.continent, dea.date, dea.population_density, vac.new_vaccinations,
sum(cast(vac.new_vaccinations AS int)) OVER (partition by dea.location order by dea.location,dea.date ) AS RollingPplVaccinated
from [Portfolio Project].[dbo].[Coviddeaths] dea
join [Portfolio Project].[dbo].[Covid_Vacc] vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select* ,(RollingPplVaccinated/population_density)*100
from PopvsVac

--TempTable
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPplVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.location, dea.continent, dea.date, dea.population_density, vac.new_vaccinations,
sum(cast(vac.new_vaccinations AS int)) OVER (partition by dea.location order by dea.location,dea.date ) AS RollingPplVaccinated
from [Portfolio Project].[dbo].[Coviddeaths] dea
join [Portfolio Project].[dbo].[Covid_Vacc] vac
	on dea.location = vac.location 
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
select * ,(RollingPplVaccinated/population)*100
from #PercentPopulationVaccinated

--views
create view PercentPopulationVaccinated as
select dea.location, dea.continent, dea.date, dea.population_density, vac.new_vaccinations,
sum(cast(vac.new_vaccinations AS int)) OVER (partition by dea.location order by dea.location,dea.date ) AS RollingPplVaccinated
from [Portfolio Project].[dbo].[Coviddeaths] dea
join [Portfolio Project].[dbo].[Covid_Vacc] vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated