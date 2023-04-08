select * 
from SQLPortfolioProject..Coviddeaths 
order by 3,4

/--select * 
--from SQLPortfolioProject..CovidVaccinations 
--order by 3,4 

Select Location , date, total_cases, new_cases, total_deaths, population
from SQLPortfolioProject..Coviddeaths
order by 1,2

-- Total cases Vs Total Deaths
--:Shows likelihood of dying if you contract covid in your country
select Location, date, total_cases, total_deaths,((try_convert(decimal(18,2),total_deaths ))/(try_convert(decimal(18,2),total_cases))*100) as Death_Percentage
from SQLPortfolioProject..Coviddeaths
--where location like '%india%'
order by 1,2 

--Looking at Total cases Vs Population
--:Shows what percentage of population got Covid  
select Location, date, total_cases, population,((try_convert(decimal(18,2),total_cases ))/(try_convert(decimal(18,2),population))*100) as Infection_Percentage
from SQLPortfolioProject..Coviddeaths
--where location like '%India%'
order by 1,2 

--Looking at Countries with Highest Infection Rate compared to Population

select Location,Population, MAX(try_convert(decimal(18,2),total_cases)) AS Highest_Infection_Count, Max((try_convert(decimal(18,2),total_cases ))/(try_convert(decimal(18,2),population))*100) as Percent_Population_Infected
from SQLPortfolioProject..Coviddeaths
Group by Location,Population
order by Percent_Population_Infected desc

--Showing countries with highest death count per population
select Location, MAX(try_convert(decimal(18,2),total_deaths)) AS Total_death_count
from SQLPortfolioProject..Coviddeaths
Group by Location,Population
order by Total_death_count desc

select Location, MAX(cast(total_deaths as int)) AS Total_death_count
from SQLPortfolioProject..Coviddeaths
Group by Location,Population
order by Total_death_count desc

select * 
from SQLPortfolioProject..Coviddeaths 
where continent is not null
order by 3,4

select Location, MAX(cast(total_deaths as int)) AS Total_death_count
from SQLPortfolioProject..Coviddeaths
where continent is not null
Group by Location,Population
order by Total_death_count desc

--Breaking down by Continents
--Showing Continents with the highest death_counts
select continent, MAX(cast(total_deaths as int)) AS Total_death_count
from SQLPortfolioProject..Coviddeaths
where continent is not null
Group by continent
order by Total_death_count desc

select location , MAX(cast(total_deaths as int)) AS Total_death_count
from SQLPortfolioProject..Coviddeaths
where continent is null
Group by location
order by Total_death_count desc

--Global Numbers

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
from SQLPortfolioProject..Coviddeaths
--where location like '%india%'
where continent is not null
where vac.new_vaccinations is not null
order by 1,2 

select new_vaccinations from SQLPortfolioProject..CovidVaccinations

--Looking at the total population Vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(try_convert(decimal(18,2),vac.new_vaccinations ))
over (partition by dea.Location Order by dea.location,dea.date) as RollingPeopleVaccinated
--Increasing_Vaccined_people
from SQLPortfolioProject..Coviddeaths dea
join SQLPortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null
order by 2,3

--USE CTE
with PopvsVac 
(Continent, Location,Date,Population, New_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(try_convert(decimal(18,2),vac.new_vaccinations ))
over (partition by dea.Location Order by dea.location,dea.date) as RollingPeopleVaccinated
--Increasing_Vaccined_people
from SQLPortfolioProject..Coviddeaths dea
join SQLPortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null
)
select * 
From PopvsVac

--Temp table
Drop Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(try_convert(decimal(18,2),vac.new_vaccinations ))
over (partition by dea.Location Order by dea.location,dea.date) as RollingPeopleVaccinated
--Increasing_Vaccined_people
from SQLPortfolioProject..Coviddeaths dea
join SQLPortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date =vac.date
--where dea.continent is not null

select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualisations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(try_convert(decimal(18,2),vac.new_vaccinations ))
over (partition by dea.Location Order by dea.location,dea.date) as RollingPeopleVaccinated
--Increasing_Vaccined_people
from SQLPortfolioProject..Coviddeaths dea
join SQLPortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null



