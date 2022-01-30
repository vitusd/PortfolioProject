--SELECT *
--FROM [Portfolio Project].dbo.CovidVaccinations
--ORDER BY 3,4

-- Select data to be used for analysis.


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project].dbo.CovidDeaths
WHERE continent IS NOT null
ORDER BY 1,2

-- Looking at total cases vs total deaths
-- Shows the likelihood of dying if covid is contracted in each country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM [Portfolio Project].dbo.CovidDeaths
WHERE location LIKE '%states%' AND continent IS NOT null
ORDER BY 1,2

-- Looking at total cases vs population
-- Shows the percentage of the population that has contracted Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS contracted_percentage
FROM [Portfolio Project].dbo.CovidDeaths
WHERE location LIKE '%states%' AND continent IS NOT null
ORDER BY 1,2

-- Looking at countries with the highest infection rate compared to population.

SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS contracted_percentage
FROM [Portfolio Project].dbo.CovidDeaths
WHERE continent IS NOT null
GROUP BY location, population
ORDER BY contracted_percentage DESC

-- Countries with the highest death count compared to population
SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM [Portfolio Project].dbo.CovidDeaths
WHERE continent IS NOT null
GROUP BY location
ORDER BY total_death_count DESC

-- Continents with the highest death count

SELECT continent, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM [Portfolio Project].dbo.CovidDeaths
WHERE continent IS NOT null
GROUP BY continent
ORDER BY total_death_count DESC


-- Global numbers

SELECT SUM(new_cases) AS total_new_cases, SUM(CAST(new_deaths AS INT)) AS total_new_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS death_percentage
FROM [Portfolio Project].dbo.CovidDeaths
WHERE continent IS NOT null
ORDER BY 1,2

-- Looking at total population compared to vaccinations

SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vaccinations.new_vaccinations, SUM(CONVERT(INT,Vaccinations.new_vaccinations)) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) AS rolling_people_vaccinated
FROM [Portfolio Project].dbo.CovidDeaths AS Deaths
JOIN [Portfolio Project].dbo.CovidVaccinations AS Vaccinations 
	ON Deaths.location = Vaccinations.location
	AND Deaths.date = Vaccinations.date
WHERE Deaths.continent IS NOT null
ORDER BY 2, 3

-- Using CTE

WITH PopvsVAC (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vaccinations.new_vaccinations, SUM(CONVERT(BIGINT,Vaccinations.new_vaccinations)) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) AS rolling_people_vaccinated
FROM [Portfolio Project].dbo.CovidDeaths AS Deaths
JOIN [Portfolio Project].dbo.CovidVaccinations AS Vaccinations 
	ON Deaths.location = Vaccinations.location
	AND Deaths.date = Vaccinations.date
WHERE Deaths.continent IS NOT null
--ORDER BY 2, 3
)
SELECT *, (rolling_people_vaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Temporary table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rolling_people_vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vaccinations.new_vaccinations, SUM(CONVERT(BIGINT,Vaccinations.new_vaccinations)) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) AS rolling_people_vaccinated
FROM [Portfolio Project].dbo.CovidDeaths AS Deaths
JOIN [Portfolio Project].dbo.CovidVaccinations AS Vaccinations 
	ON Deaths.location = Vaccinations.location
	AND Deaths.date = Vaccinations.date
--WHERE Deaths.continent IS NOT null
--ORDER BY 2, 3

SELECT *, (rolling_people_vaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creating View (for later viz)

CREATE VIEW PercentPopulationVaccinated AS
SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vaccinations.new_vaccinations, SUM(CONVERT(BIGINT,Vaccinations.new_vaccinations)) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) AS rolling_people_vaccinated
FROM [Portfolio Project].dbo.CovidDeaths AS Deaths
JOIN [Portfolio Project].dbo.CovidVaccinations AS Vaccinations 
	ON Deaths.location = Vaccinations.location
	AND Deaths.date = Vaccinations.date
WHERE Deaths.continent IS NOT null
--ORDER BY 2, 3

SELECT *
FROM PercentPopulationVaccinated