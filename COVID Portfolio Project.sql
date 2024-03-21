SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using 
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Total Cases vs Total Deaths
SELECT Location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%canada%'
ORDER BY 1,2

-- Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT Location, date, total_cases, population, (cast(total_cases as float)/population)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%canada%'
ORDER BY 1,2


-- Contries with Highest Infection Rate compared to Population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX(cast(total_cases as float)/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%canada%'
GROUP BY Location, population
ORDER BY PercentPopulationInfected desc

-- FILTERED BY CONTINENT

-- Continents with the highest death count per population
SELECT continent,MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%canada%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


-- GLOBAL NUMBERS


SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as float)) as TotalDeaths, (SUM(cast(new_deaths as float))/SUM(new_cases))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


-- Total Population vs Vaccinations
SELECT CDeaths.continent, CDeaths.location, CDeaths.date, population, CVacs.new_vaccinations
, SUM(CAST(CVacs.new_vaccinations as float)) OVER (PARTITION BY CDeaths.location ORDER BY CDeaths.location, 
CDeaths.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS CDeaths
JOIN PortfolioProject..CovidVaccinations as CVacs
	ON CDeaths.location = CVacs.location
	and CDeaths.date = CVacs.date
WHERE CDeaths.continent is not null
--WHERE CDeaths.continent is not null
ORDER BY 2,3

-- USE CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS
(
SELECT CDeaths.continent, CDeaths.location, CDeaths.date, population, CVacs.new_vaccinations
, SUM(CAST(CVacs.new_vaccinations as float)) OVER (PARTITION BY CDeaths.location ORDER BY CDeaths.location, 
CDeaths.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS CDeaths
JOIN PortfolioProject..CovidVaccinations as CVacs
	ON CDeaths.location = CVacs.location
	and CDeaths.date = CVacs.date
WHERE CDeaths.continent is not null
--WHERE CDeaths.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinatedByPopulation
FROM PopvsVac


-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT CDeaths.continent, CDeaths.location, CDeaths.date, population, CVacs.new_vaccinations
, SUM(CAST(CVacs.new_vaccinations as float)) OVER (PARTITION BY CDeaths.location ORDER BY CDeaths.location, 
CDeaths.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS CDeaths
JOIN PortfolioProject..CovidVaccinations as CVacs
	ON CDeaths.location = CVacs.location
	and CDeaths.date = CVacs.date
WHERE CDeaths.continent is not null
--WHERE CDeaths.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinatedByPopulation
FROM #PercentPopulationVaccinated


-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as 
SELECT CDeaths.continent, CDeaths.location, CDeaths.date, population, CVacs.new_vaccinations
, SUM(CAST(CVacs.new_vaccinations as float)) OVER (PARTITION BY CDeaths.location ORDER BY CDeaths.location, 
CDeaths.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS CDeaths
JOIN PortfolioProject..CovidVaccinations as CVacs
	ON CDeaths.location = CVacs.location
	and CDeaths.date = CVacs.date
WHERE CDeaths.continent is not null
--WHERE CDeaths.continent is not null
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated