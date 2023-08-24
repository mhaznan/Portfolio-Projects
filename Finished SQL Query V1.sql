SELECT * 
FROM [COVID Portfolio Project DB]..CovidDeaths
ORDER BY 3,4

--SELECT * 
--FROM [COVID Portfolio Project DB]..CovidVaccinations
--ORDER BY 3,4

-- selecting the data that we are going to be using 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [COVID Portfolio Project DB]..CovidDeaths
ORDER BY 1,2 

-- looking at total cases vs total deaths in the United States 
-- shows the likelihood of dying if you contract COVID in your country 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM [COVID Portfolio Project DB]..CovidDeaths
WHERE location like 'Malaysia'
ORDER BY 1,2 

-- Looking at total cases in terms of whole population in Malaysia
SELECT location, date, total_cases, population, (total_cases/population)*100 AS Case_Percentage
FROM [COVID Portfolio Project DB]..CovidDeaths
WHERE location = 'Malaysia'
ORDER BY 1,2 

-- what countries have the highest infection rate relative to population
SELECT continent, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM [COVID Portfolio Project DB]..CovidDeaths
GROUP by continent, population
ORDER BY 4 DESC

-- what countries have the highest death rate relative to population
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM [COVID Portfolio Project DB]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC 

-- Let's break things down by continent 

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM [COVID Portfolio Project DB]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC 

-- Showing the continents with the highest death count 
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM [COVID Portfolio Project DB]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC

-- Global Numbers 
SELECT date, SUM(CAST(new_cases AS int)) AS TotalCases,SUM(CAST(new_deaths AS int)) AS TotalDeaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM [COVID Portfolio Project DB]..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY date
ORDER BY 1,2; 

-- Day Break

SELECT * 
FROM CovidVaccinations

-- Joining the two tables together on location and date 
-- Looking at total pop vs total vacc 
-- Using a CTE 

With PopvsVac (Continent, Location, Date, Population, NewVaccinations, CumulativeVaccineCount)
AS
(
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, SUM(CAST(CV.new_vaccinations AS int)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS CumulativeVaccineCount
FROM [COVID Portfolio Project DB]..CovidDeaths AS CD
JOIN [COVID Portfolio Project DB]..CovidVaccinations AS CV
ON CD.location = CV.location
AND CD.date = CV.date
WHERE CD.continent IS NOT NULL 
--ORDER BY 2,3
)

SELECT *, (CumulativeVaccineCount/Population)*100
FROM PopvsVac

-- Temp Table 
DROP Table IF exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric, 
CumulativeVaccineCount numeric
)

Insert into #PercentPopulationVaccinated
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, SUM(CAST(CV.new_vaccinations AS int)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS CumulativeVaccineCount
FROM [COVID Portfolio Project DB]..CovidDeaths AS CD
JOIN [COVID Portfolio Project DB]..CovidVaccinations AS CV
ON CD.location = CV.location
AND CD.date = CV.date
WHERE CD.continent IS NOT NULL 
--ORDER BY 2,3

SELECT *, (CumulativeVaccineCount/Population)*100
FROM #PercentPopulationVaccinated

-- Creating a View to store data for later vizzes 

CREATE View PercentPopulationVaccinated AS
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, SUM(CAST(CV.new_vaccinations AS int)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS CumulativeVaccineCount
FROM [COVID Portfolio Project DB]..CovidDeaths AS CD
JOIN [COVID Portfolio Project DB]..CovidVaccinations AS CV
ON CD.location = CV.location
AND CD.date = CV.date
WHERE CD.continent IS NOT NULL 
--ORDER BY 2,3

-- Seeing my View 
SELECT * 
FROM PercentPopulationVaccinated









