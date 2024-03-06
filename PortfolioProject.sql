-- create database PortfolioProject

-- use portfolioprojectcoviddeaths
-- select * from coviddeaths order by 3,4
-- select * from covidVaccination order by 3,4

select * from coviddeaths where continent is not null order by 3,4

-- SELECT 
--     location,
--     date,
--     total_cases,
--     new_cases,
--     total_deaths,
--     population
-- FROM
--     coviddeaths
-- ORDER BY 1 , 2
    
-- Looking at Total Cases vs Total Deaths 
  
-- SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathPercentage
-- FROM coviddeaths where location like '%india%' ORDER BY 1 , 2
    
-- Looking at Total Cases vs Population    
-- Shows what percentage of population got covid  
  
-- SELECT location, date, total_cases, Population, (total_cases/population)*100 as DeathPercentage
-- FROM coviddeaths -- where location like '%india%' ORDER BY 1 , 2    
    
-- Looking at countries with highest rate compared to population
   
-- SELECT location, Population, max(total_cases) as HighestInfectionCount,  max((total_cases/population))*100 as PercenofpopulationInfected
-- FROM coviddeaths 
-- -- where location like '%india%'
-- group by location, population ORDER BY PercenofpopulationInfected desc      
    
-- Showing countries with highest Death Count per Population

SELECT location, max(total_deaths ) as TotalDeathCount from  coviddeaths where continent is not null
-- where location like '%india%'
group by location ORDER BY TotalDeathCount desc
    
-- Let's break things down by continent
    
SELECT continent, max(total_deaths ) as TotalDeathCount from  coviddeaths
 where continent is  not null
-- where location like '%india%'
group by continent  ORDER BY TotalDeathCount desc    
    
-- Showing continent with the highest death count per population

SELECT continent, max(total_deaths ) as TotalDeathCount from  coviddeaths
 where continent is  not null
-- where location like '%india%'
group by continent  ORDER BY TotalDeathCount desc

-- Global numbers

SELECT sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
FROM coviddeaths -- where location like '%india%' 
where continent is not null 
-- group by date  
ORDER BY 1 , 2

-- Looking at Total population as vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, 
dea.date) as rollingPeopleVaccinated, -- (rollingPeopleVaccinated/population)*100
from coviddeaths dea
join  covidvaccination vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE
	
WITH PopvsVac AS (
    SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingPeopleVaccinated
    FROM coviddeaths dea
    JOIN covidvaccination vac ON dea.location = vac.location AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *, (rollingPeopleVaccinated/population)*100
FROM PopvsVac;

-- Temp Table

create table  PercentPopulationVaccinated
(
continent varchar(255),
location varchar(255),
date datetime,
population int,
new_vaccinations int,
rollingPeopleVaccinated int
);



insert into PercentPopulationVaccinated
 SELECT
        dea.continent,
        dea.location,
        DATE_FORMAT(dea.date, '%Y-%m-%d') AS formatted_date,
        dea.population,
        vac.new_vaccinations,
        SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingPeopleVaccinated
    FROM coviddeaths dea
    JOIN covidvaccination vac ON dea.location = vac.location AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL ;
    
SELECT *, (rollingPeopleVaccinated/population)*100
FROM PercentPopulationVaccinated;