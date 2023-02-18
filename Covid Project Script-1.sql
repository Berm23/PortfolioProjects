select *
from CovidDeaths cd
where continent is not NULL 
order by 3,4;

--select *
--from CovidVaccinations cv 
--order by 3,4;

--Select Data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths cd 
where continent is not NULL 
order by 2,1;

-- Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country
select location, 
date, 
total_cases, 
total_deaths, 
(1.0 * total_deaths/total_cases) * 100 as death_percentage
from CovidDeaths cd 
where location like '%state%'
order by 1,2;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid.
select location, 
date, 
total_cases, 
population , 
(1.0 * total_cases /population) * 100 as PercentPopulationInfected
from CovidDeaths cd 
where location like '%state%'
order by 1,2;


-- Looking at Countries with highest infection rate compared to population
select location, 
population,
MAX(total_cases) as HighestInfectionCount,
MAX((1.0 * total_cases/population)) * 100 as PercentPopulationInfected
from CovidDeaths cd 
--where location like '%state%'
where continent is not NULL 
Group by location, population 
order by PercentPopulationInfected desc;


-- LETS BREAK THINGS DOWN BY CONTINENT 
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths cd 
--where location like '%state%'
where continent is not NULL 
Group by continent 
order by TotalDeathCount desc;


-- LETS BREAK THINGS DOWN BY CONTINENT 
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths cd 
--where location like '%state%'
where continent is NULL 
Group by continent 
order by TotalDeathCount desc;


select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths cd 
--where location like '%state%'
where continent is NULL 
Group by continent 
order by TotalDeathCount desc;


-- Showing Countries with highest death count per population
select location, 
MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths cd 
--where location like '%state%'
where continent is not NULL 
Group by location
order by TotalDeathCount desc;


-- Global numbers

select location, 
date,
total_cases, 
total_deaths, 
(1.0 * total_deaths/total_cases) * 100 as death_percentage
from CovidDeaths cd 
--where location like '%state%'
where continent is not NULL 
group by date
order by 1,2;

-- Global numbers grouped by date
select date,sum(new_cases) as total_cases , sum(cast(new_deaths as int)) as total_deaths , sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from CovidDeaths cd 
--where location like '%state%'
where continent is not NULL 
group by date
order by 1,2;

-- Global Numbers overall
select date,sum(new_cases) as total_cases , sum(cast(new_deaths as int)) as total_deaths , sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from CovidDeaths cd 
--where location like '%state%'
where continent is not NULL 
--group by date
order by 1,2;

-- looking at total population vs vaccinations
select *
from CovidVaccinations cv 


select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations 
from CovidDeaths cd 
join CovidVaccinations cv 
	on cd.location = cv.location 
	and cd.date = cv.date
where cd.continent is not NULL 
order by 1, 2, 3;

-- Total population plus running total on vaccinated by location by date.
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(CAST(cv.new_vaccinations as int)) over (PARTITION by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from CovidDeaths cd 
join CovidVaccinations cv 
	on cd.location = cv.location 
	and cd.date = cv.date
where cd.continent is not NULL 
order by 2, 3;

-- Total population plus running total on vaccinated by location by date with percentage
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(CAST(cv.new_vaccinations as int)) over (PARTITION by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/cd.population )*100
from CovidDeaths cd 
join CovidVaccinations cv 
	on cd.location = cv.location 
	and cd.date = cv.date
where cd.continent is not NULL 
order by 2, 3;





-- use CTE
with PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(CAST(cv.new_vaccinations as int)) over (PARTITION by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/cd.population )*100
from CovidDeaths cd 
join CovidVaccinations cv 
	on cd.location = cv.location 
	and cd.date = cv.date
where cd.continent is not NULL 
--order by 2, 3
)
Select *, (1.0 * RollingPeopleVaccinated/population)*100
from PopvsVac;



-- use CTE
with PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(CAST(cv.new_vaccinations as int)) over (PARTITION by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/cd.population )*100
from CovidDeaths cd 
join CovidVaccinations cv 
	on cd.location = cv.location 
	and cd.date = cv.date
where cd.continent is not NULL 
--order by 2, 3
)
Select *, (1.0 * RollingPeopleVaccinated/population)*100
from PopvsVac



--temp table

drop table if exists #PercentPopVacc
create table #PercentPopVacc 
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric ,
New_Vaccination numeric ,
RollingPeopleVaccinated numeric 
)
Insert into #PercentPopVacc
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(CAST(cv.new_vaccinations as int)) over (PARTITION by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/cd.population )*100
from CovidDeaths cd 
join CovidVaccinations cv 
	on cd.location = cv.location 
	and cd.date = cv.date
where cd.continent is not NULL 
--order by 2, 3
Select *, (1.0 * RollingPeopleVaccinated/cd.population)*100
from #PercentPopVacc;


--view
select date,sum(new_cases) as total_cases , sum(cast(new_deaths as int)) as total_deaths , sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from CovidDeaths cd 
--where location like '%state%'
where continent is not NULL 
--group by date
order by 1,2;

--creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(CAST(cv.new_vaccinations as int)) over (PARTITION by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/cd.population )*100
from CovidDeaths cd 
join CovidVaccinations cv 
	on cd.location = cv.location 
	and cd.date = cv.date
where cd.continent is not NULL;
--order by 2, 3
