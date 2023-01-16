-- Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
Order by 1,2

-- Total Cases vs Population
SELECT location, date, population, total_cases, (total_cases/population)*100 as infected_population_percentage
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
Order by 1,2

-- Return the percentage of deaths among the new cases everyday
-- 1
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as global_death_percentage
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
Order by 1,2

-- Returning Continents with the Highest Death Count
--2
SELECT location, SUM(cast(new_deaths as int)) as total_death_count
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is null
AND location not in ('World', 'European Union', 'International')
GROUP BY location
Order by total_death_count desc

-- Returning the percentage of the population infected for each country
--3
SELECT location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as percent_population_infected
FROM PortfolioProject.dbo.CovidDeaths
Group By location, population
Order by percent_population_infected desc

-- Returning the percentage of the population infected for each country on each date
--4
SELECT location, population, date, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as percent_population_infected
FROM PortfolioProject.dbo.CovidDeaths
Group By location, population, date
Order by percent_population_infected desc

-- Join CovidDeaths and CovidVaccinations Tables
SELECT *
FROM PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

-- Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- Return total number of vaccinations on any given date
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_vaccinations
FROM PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3;

-- Return the percentage of people vaccinated
-- Using CTE
With PopVsVac (continent, location, date, population, new_vaccinations, rolling_vaccinations)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_vaccinations
FROM PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
SELECT *, (rolling_vaccinations/population)*100 as percent_vaccinations
FROM PopVsVac
Order by 2,3

-- Using Temp Tables
DROP TABLE if exists #PercentPopulationVaccinated -- This will prevent the error caused when you try to create a table which already exists
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_Vaccinations numeric
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_vaccinations
FROM PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
SELECT *, (Rolling_Vaccinations/population)*100 as percent_vaccinations
FROM #PercentPopulationVaccinated
Order by 2,3


-- Creating Views
-- A view is a virtual table based on the result set of an SQL statement

-- Creating a View for PercentPopulationVaccinated
Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_vaccinations
FROM PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated