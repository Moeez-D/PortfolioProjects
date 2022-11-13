select location, date, total_cases, new_cases, total_deaths, population
from Portfolio1..CovidDeaths$
order by 1,2

-- looking at total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from Portfolio1..CovidDeaths$
order by 1,2

--shows likelyhood of dying if you contract covid in your country (here united states)

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from Portfolio1..CovidDeaths$
where location like	 '%States'
order by 1,2

--looking at total cases vs population
-- shows % of people that got covid

select location, date, (total_cases) , population, (total_cases/population)*100 as death_percentage_by_population
from Portfolio1..CovidDeaths$
where location like	 '%States'
order by 1,2

-- looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as highest_infection_count, Max((total_cases/population))*100 as percentage_population_infected
from Portfolio1..CovidDeaths$
group by location, population
order by percentage_population_infected desc

--showing the continent with highest death count per population

select location, max(cast(total_deaths as int)) as total_death_count
from Portfolio1..CovidDeaths$
where continent is null
group by location
order by total_death_count desc

--showing the countries with highest death count per population

select location, max(cast(total_deaths as int)) as total_death_count
from Portfolio1..CovidDeaths$
where continent is not null
group by location, population
order by total_death_count desc

--Global numbers
select date,sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_percentage
from Portfolio1..CovidDeaths$
where continent is not null
group by date
Order by 1,2		


--total global numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_percentage
from Portfolio1..CovidDeaths$
where continent is not null
--group by date
Order by 1,2

--looking at covid_vaccinations

select *
from Portfolio1..CovidVaccinations$

--joining both 
-- looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as rolling_count_vaccination
from Portfolio1..CovidDeaths$ dea
join Portfolio1..CovidVaccinations$ vac
	on dea.location = vac.location 
	and		
	dea.date = vac.date
where dea.continent is not null
order by 2,3

-- using CTE

with PopVsVac (continent, location, date, population, new_vaccination, RollingPeopleVaccincates)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as rolling_count_vaccination
from Portfolio1..CovidDeaths$ dea
join Portfolio1..CovidVaccinations$ vac
	on dea.location = vac.location 
	and		
	dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccincates/population)*100
from PopVsVac

--temp table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccincates numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccincates
from Portfolio1..CovidDeaths$ dea
join Portfolio1..CovidVaccinations$ vac
	on dea.location = vac.location 
	and		
	dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccincates/population)*100
from #PercentPopulationVaccinated

--creating view to store data for later visualisation

create view PercentPopulationVaccinated as 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccincates
from Portfolio1..CovidDeaths$ dea
join Portfolio1..CovidVaccinations$ vac
	on dea.location = vac.location 
	and		
	dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
from PercentPopulationVaccinated
