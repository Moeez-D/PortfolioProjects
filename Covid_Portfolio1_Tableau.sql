
--Query 1
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from Portfolio1..CovidDeaths$
where continent is not null
order by 1,2

--Query2
select location, sum(cast(new_deaths as int)) as TotalDeathCount
from Portfolio1..CovidDeaths$
where continent is null
and location not in ('World','European Union','International')
Group by location
order by TotalDeathCount desc

--Query3
select location, population, MAX(total_cases) as HighestInfectionCount, Max(Total_cases/population)*100 as PercentPopulationInfected
from Portfolio1..CovidDeaths$
group by location, population
order by PercentPopulationInfected desc

--Query4
select location, population, date, max(total_cases) as HighestInfectionCount, Max(Total_cases/population)*100 as PercentPopulationInfected
from Portfolio1..CovidDeaths$
group by location, population, date
order by PercentPopulationInfected desc
