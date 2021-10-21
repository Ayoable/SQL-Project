USE MyPortfolioProject
select *
from MyPortfolioProject..CovidDeath
where continent is not null
order by 3, 4

--select *
--from MyPortfolioProject..CovidVaccinations
--order by 3, 4

--selecting the data to use

select location,date, total_cases, new_cases, total_deaths, population 
from MyPortfolioProject..CovidDeath
order by 1, 2

--looking at total cases vs total death
-- shows the likelihood if you contract covid in your contry
select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage 
from MyPortfolioProject..CovidDeath
where location like '%kingdom%'
order by 1, 2

--looking at total cases vs population
-- shows the percentage of population that got covid

select location,date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected 
from MyPortfolioProject..CovidDeath
where location like '%kingdom%'
order by 1, 2

--Countries with highest infection rate compared to population

select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected  
from MyPortfolioProject..CovidDeath
--where location like '%kingdom%'
Group by location, population
order by PercentPopulationInfected desc

--Highest death countries per population

select location, MAX(cast(total_deaths as int)) as TotalDeathcount  
from MyPortfolioProject..CovidDeath
--where location like '%kingdom%'
where continent is not null
Group by location
order by TotalDeathcount desc

--BREAKING THINGS BY CONTINENT 
-- showing Continent with highest death count per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathcount  
from MyPortfolioProject..CovidDeath
--where location like '%kingdom%'
where continent is not null
Group by continent
order by TotalDeathcount desc

select location, MAX(cast(total_deaths as int)) as TotalDeathcount  
from MyPortfolioProject..CovidDeath
--where location like '%kingdom%'
where continent is null
Group by location
order by TotalDeathcount desc

--GLOBAL NUMBER

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int))as total_death, SUM(cast(new_deaths as int))/SUM(total_cases)*100 as DeathPercentage 
from MyPortfolioProject..CovidDeath
--where location like '%kingdom%'
where continent is not null
Group by date
order by 1, 2

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int))as total_death, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
from MyPortfolioProject..CovidDeath
--where location like '%kingdom%'
where continent is not null
--Group by date
order by 1, 2

-- Total Population vs Vaccination
select *
From MyPortfolioProject..CovidDeath dea 
Join MyPortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date

-- Total Population vs Vaccination
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
From MyPortfolioProject..CovidDeath dea 
Join MyPortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER(partition by dea.location order by dea.location, dea.date)as RollingPeopleVaccinated
From MyPortfolioProject..CovidDeath dea 
Join MyPortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER(partition by dea.location order by dea.location, dea.date)as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From MyPortfolioProject..CovidDeath dea 
Join MyPortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE
with popvsvac (continent, location, date, population,new_vaccination, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER(partition by dea.location order by dea.location, dea.date)as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From MyPortfolioProject..CovidDeath dea 
Join MyPortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/population)*100
From popvsvac


--TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER(partition by dea.location order by dea.location, dea.date)as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From MyPortfolioProject..CovidDeath dea 
Join MyPortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *,(RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visualisations

--Create View PercentPopulationVaccinated as 
--select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
--, SUM(CONVERT(int,vac.new_vaccinations)) OVER(partition by dea.location order by dea.location, dea.date)as RollingPeopleVaccinated
----, (RollingPeopleVaccinated/population)*100
--From MyPortfolioProject..CovidDeath dea 
--Join MyPortfolioProject..CovidVaccinations vac
--On dea.location = vac.location
--and dea.date = vac.date
--where dea.continent is not null
----order by 2,3

Drop view if exists PercentPopulationVaccinated  
GO
Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER(partition by dea.location order by dea.location, dea.date)as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From MyPortfolioProject..CovidDeath dea 
Join MyPortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated