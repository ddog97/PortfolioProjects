SELECT *
FROM CovidDeaths
WHERE continent is not null
order by 3,4

--SELECT *
--FROM CovidVaccinations
--order by 3,4

-- The data we will be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 AS DeathPercentage
FROM CovidDeaths
WHERE Location like 'Australia' and continent is not null
ORDER BY Location, CONVERT(DATE, date, 104) asc

-- Looking at Total Cases vs Population
-- Shows what percentage of the population that contracted COVID-19
SELECT Location, date, total_cases, population, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 AS PercentagePopulationInfected
FROM CovidDeaths
WHERE Location like 'Australia' and continent is not null
ORDER BY Location, CONVERT(DATE, date, 104) asc


--Countries that have the highest infection rates compared to the population


SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)))*100 AS PercentagePopulationInfected
FROM CovidDeaths
WHERE continent is not null
Group BY location, population
ORDER BY PercentagePopulationInfected DESC

-- COVID-19 breakdown by Continent
-- Continents with the highest death count per population

SELECT continent,MAX(cast(total_deaths as float)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
Group BY continent
ORDER BY TotalDeathCount DESC


-- The countries with the Highest Mortality Rate per Population
SELECT location,MAX(cast(total_deaths as float)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
Group BY location
ORDER BY TotalDeathCount DESC


-- Global Breakdown
SELECT date, SUM(cast(new_cases as int)) AS GlobalCases, SUM(cast(new_deaths as int)) AS GlobalDeaths, (SUM(CAST(new_deaths as float)) / NULLIF(SUM(cast(new_cases as float)),0)) * 100 AS DeathPercentage
FROM CovidDeaths
Where continent is not null
Group by date
ORDER BY CONVERT(DATE, date, 104) asc, 2



-- Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS RollingCountVaccinations
FROM CovidDeaths AS dea
INNER JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER by 2,3

-- USE CTE
WITH PopVsVac (Continent, Location, Date, Population, new_vaccinations, RollingCountVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS RollingCountVaccinations
FROM CovidDeaths AS dea
INNER JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER by 2,3
)

SELECT *, (RollingCountVaccinations/Population)*100
From PopVsVac

-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingCountVaccinations numeric
)
INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS RollingCountVaccinations
FROM CovidDeaths AS dea
INNER JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null

SELECT *, (RollingCountVaccinations/Population)*100
From #PercentPopulationVaccinated

--Create Views
CREATE VIEW PercentPopulationVaccineted AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS RollingCountVaccinations
FROM CovidDeaths AS dea
INNER JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
-- order by

SELECT *
FROM PercentPopulationVaccineted