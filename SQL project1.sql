select *
from NewPortfolioProject..CovidDeaths$
where continent is not null
order by 3,4



--select *
--from NewPortfolioProject..CovidVaccination$
--order by 3,4

--select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from NewPortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

--Looking at total cases vs total death
--Shows the likelihood of dying if you contract Covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from NewPortfolioProject..CovidDeaths$
where location = 'nigeria' and continent is not null
order by 1,2

-- Looking at the Total cases vs Population
-- Shows the percentage of the population that contracted Covid

select location, date, population, total_cases, (total_cases/population)*100 as Contracted_Percentage
from NewPortfolioProject..CovidDeaths$
where location = 'nigeria' and continent is not null
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

select location, population, max(total_cases) as Highest_Infection_Count, max((total_cases/population))*100 as Highest_Contracted_Percentage
from NewPortfolioProject..CovidDeaths$
where continent is not null
--where location = 'nigeria'
group by location, population
order by Highest_Contracted_Percentage desc


-- Showing Countries with Highest Death Count Per Population

select location, max(cast(total_deaths as int)) as Total_Death_Count
from NewPortfolioProject..CovidDeaths$
where continent is not null
group by location
order by Total_Death_Count desc


--Breaking down by Continent
-- Showing the Continent with the Highest death count

select continent, max(cast(total_deaths as int)) as Total_Death_Count
from NewPortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by Total_Death_Count desc


-- GLOBAL NUMBERS

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum (new_cases)*100 as DeathPercentage
from NewPortfolioProject..CovidDeaths$
where continent is not null
--group by date
order by 1,2


-- Looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as total_vaccinations
from NewPortfolioProject..CovidDeaths$ dea
join NewPortfolioProject..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3




--Use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, total_vaccinations)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as total_vaccinations
from NewPortfolioProject..CovidDeaths$ dea
join NewPortfolioProject..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (total_vaccinations/population)*100 as percentage_vaccinated
from PopvsVac




-- Temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
total_vaccinations numeric
)

insert into #PercentPopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as total_vaccinations
from NewPortfolioProject..CovidDeaths$ dea
join NewPortfolioProject..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (total_vaccinations/population)*100 as percentage_vaccinated
from #PercentPopulationVaccinated




-- creating view to store data for visualization

create view PercentPopulationVaccinatedView as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as total_vaccinations
from NewPortfolioProject..CovidDeaths$ dea
join NewPortfolioProject..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinatedView