---Covid 19 Data Exploration in SQL
--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

SELECT *
FROM ProjectA..CovidDeaths
WHERE continent is NOT NULL
Order by 3,4

--Select data to be used

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM ProjectA..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2

--Total cases Vs Total deaths

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM ProjectA..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Likelihood of dying in Africa if you contract Covid

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM ProjectA..CovidDeaths
WHERE location like '%Africa%'
and continent is not null
ORDER BY 1,2

--Total cases vs Total population
--Shows percentage of population infected with Covid

SELECT location,date,total_cases,population,(total_cases/population)*100 as CovPercentage
FROM ProjectA..CovidDeaths
ORDER BY 1,2

--Countries with highest infection rate Compared to population

SELECT location,MAX (total_cases),population,MAX((total_cases/population))*100 as CovPercentage
FROM ProjectA..CovidDeaths
WHERE continent is NOT NULL
GROUP BY location,population
ORDER BY CovPercentage DESC

--Countries with Highest Death count per population

SELECT location,MAX (Cast (total_deaths as int)) as Totaldeath
FROM ProjectA..CovidDeaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY Totaldeath DESC

--Breaking things down by Continent
--Continents with highest death count

SELECT continent,MAX (Cast (total_deaths as int)) as Totaldeath
FROM ProjectA..CovidDeaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY Totaldeath DESC

--Continents with HighestInfection rate

SELECT continent,MAX (total_cases) as maxcases,MAX((total_cases/population))*100 as CovPercentage
FROM ProjectA..CovidDeaths
WHERE continent is NOT NULL
GROUP BY Continent
ORDER BY CovPercentage DESC

--Global numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM ProjectA..CovidDeaths
WHERE continent is not null 
ORDER BY 1,2

SELECT date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM ProjectA..CovidDeaths
WHERE continent is not null 
GROUP BY date
ORDER BY 1,2

SELECT *
FROM ProjectA..CovidVaccinations

--Joins between the tables
--Inner Join

SELECT *
FROM ProjectA..CovidDeaths dea
JOIN ProjectA..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date =vac.date

--Full outer join

SELECT *
FROM ProjectA..CovidDeaths dea
FULL OUTER JOIN ProjectA..CovidVaccinations vac
ON dea.location = vac.location
and dea.date=vac.date

--Total population vs vaccination

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
FROM ProjectA..CovidDeaths dea
FULL OUTER JOIN ProjectA..CovidVaccinations vac
ON dea.location = vac.location
and dea.date=vac.date
WHERE dea.continent is NOT NULL
ORDER BY 1,2,3

--Percentage of people that have received at least one covid vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) as Vaccinatedpeople
FROM ProjectA..CovidDeaths dea
JOIN ProjectA..CovidVaccinations vac
ON dea.location = vac.location
and dea.date=vac.date
WHERE dea.continent is NOT NULL
ORDER BY 1,2,3

--OR 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(CONVERT(INT,vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) as Vaccinatedpeople
FROM ProjectA..CovidDeaths dea
JOIN ProjectA..CovidVaccinations vac
ON dea.location = vac.location
and dea.date=vac.date
WHERE dea.continent is NOT NULL
ORDER BY 1,2,3

--USING CTE

WITH PopsvsVac (continent,location,date,population,new_vaccinations,Vaccinatedpeople)
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(CONVERT(INT,vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) as Vaccinatedpeople
FROM ProjectA..CovidDeaths dea
JOIN ProjectA..CovidVaccinations vac
ON dea.location = vac.location
and dea.date=vac.date
WHERE dea.continent is NOT NULL)

SELECT *
FROM PopsvsVac

-- Using CTE to perform Calculation on Partition By in previous query

WITH PopsvsVac (continent,location,date,population,new_vaccinations,Vaccinatedpeople)
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(CONVERT(INT,vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) as Vaccinatedpeople
FROM ProjectA..CovidDeaths dea
JOIN ProjectA..CovidVaccinations vac
ON dea.location = vac.location
and dea.date=vac.date
WHERE dea.continent is NOT NULL)

SELECT * ,(Vaccinatedpeople/population)*100
FROM PopsvsVac

--TEMP TABLE
--Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PerPeopleVacc
CREATE TABLE #PerPeopleVacc
( continent nvarchar (300),
location nvarchar(300),
date datetime,
population numeric,
new_vaccinations numeric,
Vaccinatedpeople numeric)

INSERT INTO #PerPeopleVacc
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(CONVERT(INT,vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) as Vaccinatedpeople
FROM ProjectA..CovidDeaths dea
JOIN ProjectA..CovidVaccinations vac
ON dea.location = vac.location
and dea.date=vac.date
WHERE dea.continent is NOT NULL

SELECT * ,(Vaccinatedpeople/population)*100
FROM #PerPeopleVacc

-- Creating View to store data for later visualizations

CREATE VIEW PerPeopleVacc as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Vaccinatedpeople
FROM ProjectA..CovidDeaths dea
Join ProjectA..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null  
