use side_project;


-- Check if data is loaded correctly

select * 
from coviddeaths
order by 3, 4;

select * 
from covidvaccinations
order by 3, 4;


-- Select needed data

select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
Where continent != ''
order by 1, 2;


-- Look at total cases vs total deaths
-- Show the likelihood of dying if you get covid in the spepcific location
 
select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,2) as DeathRate
from coviddeaths
Where continent != ''
-- and location = 'United States' -- filter data by location
order by 1, 2;


-- Look at total cases vs populations

select location, date, population, total_cases, round((total_cases/population)*100,2) as InfectiondRate
from coviddeaths
Where continent != ''
-- and location = 'United States' -- filter data by location
order by 1, 2;


-- Countries with highest infection rate compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as InfectiondRate
From CovidDeaths
Where continent != ''
-- and location = 'United States'
Group by Location, Population
order by InfectiondRate DESC;


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as UNSIGNED)) as TotalDeathCount
From CovidDeaths
-- Where location = 'United States'
where continent != ''
Group by Location
order by TotalDeathCount DESC;


-- Showing contintents with the highest death count per population

With CountryDeathCount as (Select Continent, Location, MAX(cast(Total_deaths as UNSIGNED)) as TotalDeathCount
From CovidDeaths
-- Where location = 'United States'
where continent != ''
Group by Continent, Location
order by TotalDeathCount DESC)

select Continent, sum(TotalDeathCount) as TotalDeathCount
from CountryDeathCount
group by Continent
order by TotalDeathCount DESC;


-- Create View to store data

Create View TotalDeathCount as
With CountryDeathCount as (Select Continent, Location, MAX(cast(Total_deaths as UNSIGNED)) as TotalDeathCount
From CovidDeaths
-- Where location = 'United States'
where continent != ''
Group by Continent, Location
order by TotalDeathCount DESC)

select Continent, sum(TotalDeathCount) as TotalDeathCount
from CountryDeathCount
group by Continent
order by TotalDeathCount DESC;


-- Showing globally
-- Total

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
where continent != ''
order by 1,2; 


-- Create View to store data

Create view GlobalDeathPercentage as
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
where continent != ''
order by 1,2; 


-- By date

Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
where continent != ''
Group By date
order by 1, 2; 


-- Total population vs vaccination

select d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(new_vaccinations) over (partition by d.location order by d.location, d.date) as RollingPplVaccinated
from coviddeaths d
join covidvaccinations v
	on d.location = v.location AND d.date = v.date
where d.continent != ''
order by 2,3;


-- Show Percentage of population that received covid vaccines

-- (1) Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(v.new_vaccinations) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
From CovidDeaths d
Join CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
where d.continent != ''
)
Select *, round((RollingPeopleVaccinated/Population)*100, 2)
From PopvsVac;


-- (2) Use Temp Table

DROP Table if exists PercentPopulationVaccinated;
Create Table PercentPopulationVaccinated (
Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);

Insert into PercentPopulationVaccinated
select d.continent, d.location, d.date, d.population, cast(v.new_vaccinations as unsigned), 
	sum(cast(v.new_vaccinations as unsigned)) over (partition by d.location order by d.location, d.date) as RollingPplVaccinated
from coviddeaths d
join covidvaccinations v
	on d.location = v.location AND d.date = v.date;

select *
from PercentPopulationVaccinated;


-- Create View to store data for later visualizations

Create View PercentPopulationVaccinated as 
select d.continent, d.location, d.date, d.population, new_vaccinations, 
	sum(cast(v.new_vaccinations as unsigned)) over (partition by d.location order by d.location, d.date) as RollingPplVaccinated
from coviddeaths d
join covidvaccinations v
	on d.location = v.location AND d.date = v.date;



