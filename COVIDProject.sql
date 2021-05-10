SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1, 2

--Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract COVID in your country
SELECT Location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE total_deaths IS NOT Null AND location like '%states%'
order by 1, 2

-- Looking at Total Cases vs Population
-- Shows the percentage of population who contracted COVID
SELECT Location, date, total_cases, Population, ROUND((total_cases/Population)*100,2) as ContractionPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
order by 1, 2


-- Looking at countries with the Highest Infection rate compared to the Population
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX(ROUND((total_cases/Population)*100,2)) as ContractionPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY Location, Population
--WHERE location like '%states%'
ORDER BY ContractionPercentage desc


-- Breaking the observations down by continent

-- Showing the Countries with Highest Death Count per Population
-- cast used for datatype issue with 'Total_deaths'
-- want to remove continents and 'world', so 'Where continent IS NOT NULL'
SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount desc


-- Continent view
SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount desc


-- Showing the continents with the highest death count per population
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

-- Current total death percentage (at 10/05/2021)
SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--Group By date
ORDER BY 1, 2




-- Looking at Total Population vs Vaccinations
-- We want to have a carry count of all vaccinations, so we will add a new column at the end

-- USE CTE (common table expression)
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, CarryCountVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location,
dea.date) AS CarryCountVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (CarryCountVaccinated/Population)*100
FROM PopvsVac


-- TEMP Table
DROP TABLE if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
CarryCountVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location,
dea.date) AS CarryCountVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *, (CarryCountVaccinated/Population)*100
FROM #PercentPopulationVaccinated



-- Creating View to store data for later visualisations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location,
dea.date) AS CarryCountVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

-- Testing the view. We can connect this to Tableau.
SELECT *
FROM PercentPopulationVaccinated