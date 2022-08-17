SELECT *
FROM [portfolio project]..CovidVaccinations$
ORDER BY 3,4

SELECT *
FROM [portfolio project]..CovidDeaths$
WHERE continent is not NULL
ORDER BY 3,4

--select data that are going to using

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM [portfolio project]..CovidDeaths$
ORDER BY 1,2

--loooking at total deaths vs total cases
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 As 'Death Percentage'
FROM [portfolio project]..CovidDeaths$
WHERE location LIKE '%states%'
ORDER BY 1,2


--looking at total case vs population
SELECT location,date,total_cases,population,(total_cases/population)*100 As 'case percentage'
FROM [portfolio project]..CovidDeaths$
--WHERE location LIKE '%states%'
ORDER BY 1,2


--loooking with highest infection rate
SELECT location,MAX(total_cases) as 'Highest infection',population,MAX((total_cases/population))*100 As 'max case percentage'
FROM [portfolio project]..CovidDeaths$
GROUP BY location,population
--WHERE location LIKE '%states%'
ORDER BY 'max case percentage' DESC


--loooking  countries highest death  rate 
SELECT location,MAX(CAST(total_deaths as int)) as 'Highest deaths'
FROM [portfolio project]..CovidDeaths$
WHERE continent is not NULL
GROUP BY location
--WHERE location LIKE '%states%'
ORDER BY 'Highest deaths'DESC

--lets break by continent



--showing the cintinent with 

SELECT continent,MAX(CAST(total_deaths as int)) as 'continent Highest deaths'
FROM [portfolio project]..CovidDeaths$
WHERE continent is not NULL
GROUP BY continent
--WHERE location LIKE '%states%'
ORDER BY 'continent Highest deaths'DESC


--Breaking GLOBAL NUMBERS
SELECT sum(new_cases) AS 'total cases' ,SUM(CAST(new_deaths as int)) AS 'total deaths' ,(SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 As 'Death Percentage'
FROM [portfolio project]..CovidDeaths$
--WHERE location LIKE '%states%'
WHERE continent is not NULL
--GROUP BY location,date
ORDER BY 1,2

--looking total population vs vaccinated

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(INT,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location,dea.date) 
as 'rollingpeoplevaccinated'
FROM [portfolio project]..CovidDeaths$ dea
JOIN [portfolio project]..CovidVaccinations$ vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent is not NULL
ORDER by 2,3

--use cte
WITH Popvsvac (Continent,Location,Date,Population,New_vaccinations,rollingpeoplevaccinated)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(INT,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location,dea.date) 
as 'rollingpeoplevaccinated'
FROM [portfolio project]..CovidDeaths$ dea
JOIN [portfolio project]..CovidVaccinations$ vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent is not NULL
--ORDER by 2,3
)
SELECT *,(rollingpeoplevaccinated/Population)*100 as 'percentage of rolling people vaccinated'
FROM Popvsvac



---temp table
CREATE TABLE percentagepopulationvaccination
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinated numeric,
Rollingpeoplevaccinated numeric
)

INSERT INTO percentagepopulationvaccination
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(INT,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location,dea.date) 
as 'rollingpeoplevaccinated'
FROM [portfolio project]..CovidDeaths$ dea
JOIN [portfolio project]..CovidVaccinations$ vac
ON dea.location=vac.location
AND dea.date=vac.date
--WHERE dea.continent is not NULL
--ORDER by 2,3


SELECT *,(Rollingpeoplevaccinated/Population)*100 as 'percentage of rolling people vaccinated'
FROM percentagepopulationvaccination



--creating view to store 

CREATE VIEW
Percentagepopulationvaccinated
as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(INT,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location,dea.date) 
as 'rollingpeoplevaccinated'
FROM [portfolio project]..CovidDeaths$ dea
JOIN [portfolio project]..CovidVaccinations$ vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent is not NULL

SELECT * FROM percentagepopulationvaccination