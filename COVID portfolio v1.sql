Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

-- Select the Data that we are going to use	

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1, 2



-- Looking at Total Cases vs Total Deaths
-- Showing likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1, 2


-- Looking at Total Cases vs Population
-- Showing what percentage of population got covid

Select location, date, total_cases, population, (total_cases/population)*100 as InfectionPercentage
From PortfolioProject..CovidDeaths
Where location like '%China%'
Order by 1, 2


-- Looking at Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) HighestInfectionCount, MAX((total_cases/population))*100 as InfectionPercentage
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
Group by location, population
Order by InfectionPercentage desc


-- Showing Countries with Highest Death Count per Population

Select location, Max(total_deaths) TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
Where continent is not null
Group by location
Order by TotalDeathCount desc


-- Breaking things down by continent

Select location, Max(total_deaths) TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
Where (continent is null) and (location <> 'World' and location <> 'High income' and location <> 'Upper middle income' and location <> 'lower middle income' and location <> 'Low income' and location <> 'European Union')
Group by location
Order by TotalDeathCount desc


-- Global numbers

Select date, SUM(total_cases) TotalCases, SUM(total_deaths) TotalDeaths, SUM(total_deaths)/SUM(total_cases)*100 DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1

--Select date, total_cases, total_deaths
--From PortfolioProject..CovidDeaths
--Where location = 'World'
--Order by 1



-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
Order by 2, 3


-- Use CTE

With PopvsVac (Continent, location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
-- Order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100 PeopleVaccinatedPercentage
From PopvsVac



--Temp table

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100 
From #PercentPopulationVaccinated


-- Creating View to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
-- Order by 2, 3