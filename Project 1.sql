--Looking at total deaths vs total Covid-19 cases in South Africa
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deathPerc
FROM CovidDeathsEdited
WHERE location = 'South Africa'
ORDER BY 1,2

--shows the total Covid-19 cases that have been recorded in each country
SELECT location, COUNT(new_cases) AS newCasesPerPlace
FROM CovidDeathsEdited
GROUP BY location 

--shows what population is affected by Covid-19 for countries that contain the word South
SELECT location,date, total_cases, population, (total_cases/population)*100 AS CasesPerc
FROM CovidDeathsEdited
WHERE location LIKE '%south%'

--shows countries with highest infection rate
SELECT location,population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS InfectedPerc
FROM CovidDeathsEdited
GROUP BY location, population
ORDER BY InfectedPerc DESC

--shows countries with the highest death count per population
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeathsEdited
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeathCount desc

--shows continents with the highest death count
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeathsEdited
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--global numbers
--shows total cases vs total deaths in each country per day
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPerc
FROM CovidDeathsEdited
WHERE total_deaths IS NOT NULL AND total_cases IS NOT NULL
ORDER BY 2, 1

--shows total cases vs population per continent, per day
SELECT continent, date,population, total_cases, (total_cases/population) * 100 AS DeathPercentage
FROM CovidDeathsEdited
WHERE continent IS NOT NULL
ORDER BY DeathPercentage DESC

---breaking down statistics by continents
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeathsEdited
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--LOOKING AT GLOBAL NUMBERS
--shows the rate of deaths vs new cases per day globally
SELECT date, SUM(new_cases) AS new_cases,SUM(new_deaths) AS new_deaths, (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPerc
FROM CovidDeathsEdited
WHERE continent IS NOT NULL AND new_deaths IS NOT NULL
GROUP BY date
ORDER BY 1,2 DESC

--shows the rate of death 
SELECT SUM(new_cases) AS new_cases,SUM(new_deaths) AS new_deaths, (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPerc
FROM CovidDeathsEdited
WHERE continent is not null
ORDER BY 1,2 DESC


--LOOKING AT THE  TOTAL POPUATION VS VACCINATIONS
--USING CTEs
WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingVac)
AS
(
SELECT Death.continent, Death.location, Death.date, Death.population, Vacc.new_vaccinations,
SUM(CAST(Vacc.new_vaccinations as int)) OVER (PARTITION BY Death.location
ORDER BY death.location, death.date) AS RollingVacc
FROM CovidDeathsEdited AS Death
JOIN PortfolioProject1..CovidVaccinationsEdited AS Vacc
ON Death.date = Vacc.date
AND Death.location = Vacc.location
WHERE DEATH.continent IS NOT NULL
)

SELECT *, (RollingVac/population)*100 AS PopVaccinate
FROM PopVsVac
ORDER BY 2,3

--USING TEMP TABLE
DROP TABLE IF EXISTS #populationPercentage
CREATE TABLE #populationPercentage
(
continent nvarchar(50),
location nvarchar(50),
date date,
population numeric,
newVaccinations numeric,
rollingVaccs numeric
)
insert into #populationPercentage
SELECT Death.continent, Death.location, Death.date, Death.population, CONVERT(int,Vacc.new_vaccinations),
SUM(CAST(Vacc.new_vaccinations AS int)) OVER (PARTITION BY Death.location
ORDER BY death.location, death.date) AS RollingVacc
FROM CovidDeathsEdited AS Death
JOIN PortfolioProject1..CovidVaccinationsEdited AS Vacc
ON Death.date = Vacc.date
AND Death.location = Vacc.location
WHERE DEATH.continent IS NOT NULL

SELECT *, (RollingVaccs/Population)*100 AS PopVaccinate
FROM #populationPercentage
ORDER BY 2,3


--USING VIEW FOR LATER VISUALIZATION
CREATE VIEW PercentPopVacc AS
SELECT Death.continent, Death.location, Death.date, Death.population, Vacc.new_vaccinations,
SUM(CAST(Vacc.new_vaccinations AS int)) OVER (PARTITION BY Death.location
ORDER BY death.location, death.date) AS RollingVaccinations
FROM CovidDeathsEdited AS Death
JOIN PortfolioProject1..CovidVaccinationsEdited AS Vacc
ON Death.date = Vacc.date
AND Death.location = Vacc.location
WHERE DEATH.continent IS NOT NULL

SELECT *
FROM PercentPopVacc