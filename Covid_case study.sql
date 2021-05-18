-- understand each dataset start with covid deaths
select * 
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4;

-- start with covid vaccinations
select *
from PortfolioProject..CovidVaccinations$
where continent is not null 
order by 3,4


--explore the data more
select location,date, total_cases,new_cases, total_deaths 
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2;

--explore data total cases vs total deaths
select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_vs_infected
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2;

--check the location of India
--shows likelihood of dying if you contract covid in your country
select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_vs_Infected
from PortfolioProject..CovidDeaths$
where location like '%India%' and continent is not null
order by 1,2;

--worldwide
select location, MAX(total_cases) as max_cases, MAX(total_deaths) as max_deaths, MAX((total_deaths/total_cases))*100 as Death_vs_Infected
from PortfolioProject..CovidDeaths$
where continent is not null
group by location
order by 2,3;

-- explore data total cases vs population
-- what percentage of the total population contracted covid
select location,date,population, total_cases, (total_cases/population)*100 as Percentage_infected
from PortfolioProject..CovidDeaths$
where continent is not null and location like '%India%'
group by location,population,date, total_cases
order by date ;

--worldwide
select location, MAX(total_cases) as max_cases, population, MAX((total_cases/population))*100 as Percentage_infected
from PortfolioProject..CovidDeaths$
where continent is not null
group by location,population
order by Percentage_infected desc;

-- what percentage of the total population dying due to covid
select location,date,population, total_deaths, (total_deaths/population)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null and location like '%India%'
order by 1,2;

--worldwide-- countries with highest death count per population
-- change the data type of total deaths as the data type is nvarchar
select location, MAX(cast(total_deaths as int)) as max_death, population, MAX((total_deaths/population))*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
group by location,population
order by max_death desc;

--continent wise death count
-- stating where continents were null
select location, MAX(cast(total_deaths as int)) as max_death, MAX((total_deaths/population))*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is null
group by location
order by DeathPercentage desc;

-- day wise per day new cases and new deaths
select date, SUM(new_cases) as newcasetotal, SUM(cast(new_deaths as int)) as newdeathtotal, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
from PortfolioProject..CovidDeaths$
where continent is not null
group by date
order by 1,2;

-- total new cases and total new deaths
select SUM(new_cases) as newcasetotal, SUM(cast(new_deaths as int)) as newdeathtotal, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
from PortfolioProject..CovidDeaths$
where continent is not null
--group by date
order by 1,2;

--Total populations vs vaccinations worldwide
select dea.continent,dea.location,dea.population, MAX(cast(vac.total_vaccinations as int)) as max_vac,MAX(cast(vac.total_vaccinations as int))/dea.population*100 as vaccine_percentage
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date= vac.date
where dea.continent is not null
group by dea.continent,dea.location,dea.population
order by max_vac desc;

-- Countries with atleast 1 covid doses
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location 
,dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date= vac.date
where dea.continent is not null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query
with popvsvac (Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated) 
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location 
,dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date= vac.date
where dea.continent is not null
--order by 2,3
)
select * ,(RollingPeopleVaccinated/population)*100
from popvsvac

--Temp table
--drop table if exists #PercentPopVaccinated

create table #PercentPopVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location 
,dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date= vac.date
--where dea.continent is not null
--order by 2,3

select * ,(RollingPeopleVaccinated/population)*100
from #PercentPopVaccinated

--Creating data to store for later visualizations

Create View PercentPopVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location 
,dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
    on dea.location=vac.location
   and dea.date= vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopVaccinated
