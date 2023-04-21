/*
Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Table, Windows Functions, Aggregate Functions, Creating views, Converting Data Types

*/


Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select Data to start with

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

--Total cases vs Total deaths
--Shows likehood of dying from covid if contracted

Select location, date, total_cases, total_deaths, (CAST(total_deaths as float)) / (total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Nigeria%'
and continent is not null
order by 1,2


--Total cases vs Populations
--Shows what percentage of population are infected with covid

Select location, date, population, total_cases, (total_cases / population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%Nigeria%'
order by 1,2


--Countries with Highest Infection Rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases / population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%Nigeria%'
Group by location, population
order by PercentPopulationInfected desc


--Countries with Highest Death Count per Population

Select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Nigeria%
Where continent is not null
Group by location
order by TotalDeathCount desc


--Continents with highest death count

Select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Nigeria%
Where continent is not null
Group by continent
order by TotalDeathCount desc



--GLOBAL NUMBERS
--Total cases, total deaths and the death percentage across the world

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Nigeria%
where continent is not null
--Group by date
order by 1,2


--Total Population vs Vaccinations
--Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(numeric, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
Where dea.continent is not null
order by 2,3


--Using CTE to perform calculation on Partition by in previous query

With PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(numeric, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


--Using Temp Table to perform calculation on Partition by in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(numeric, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(numeric, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
where dea.continent is not null

Select *
From PercentPopulationVaccinated