Select *
From PortfolioProject..CovidDeaths$
Where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations$
--Order by 3,4

-- Select Data that we are going to be using

Select location,date,total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Where continent is not null
Order by 1,2

-- Looking at Total Case vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location,date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%france%'
Order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select location,date,total_cases, population, (total_cases/population)*100 as InfectedPopulationPercentage
From PortfolioProject..CovidDeaths$
Where location like '%france%'
Order by 1,2

-- Looking at Contries with Highet Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as InfectedPopulationPercentage
From PortfolioProject..CovidDeaths$
-- Where location like '%france%'
Where continent is not null
Group by location, population
Order by InfectedPopulationPercentage desc

-- Showing Countries with Highest Death Count per Population

Select location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths$
-- Where location like '%france%'
Where continent is not null
Group by location
Order by TotalDeathCount desc

-- Showing Continents with Highest Death Count per Population

Select continent, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths$
-- Where location like '%france%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, ( SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where continent is not null
and new_cases !=0
--Group By date
Order by 1,2


-- Looking at Total Population vs Vaccinations

Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition By dea.location Order by dea.location, dea.Date) As RollingPeapleVaccinated
-- , (RollingPeapleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order By 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeapleVaccinated)
as
(
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition By dea.location Order by dea.location, dea.Date) As RollingPeapleVaccinated
-- , (RollingPeapleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- Order By 2,3
)
Select *, (RollingPeapleVaccinated/Population)*100
From PopvsVac
Order by 2,3


-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeapleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition By dea.location Order by dea.location, dea.Date) As RollingPeapleVaccinated
-- , (RollingPeapleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
-- Where dea.continent is not null
-- Order By 2,3

Select *, (RollingPeapleVaccinated/Population)*100
From #PercentPopulationVaccinated
Order by 2,3


-- Creating View to stare Data for later Visualizations

Create View PercentPopulationVaccinated as
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition By dea.location Order by dea.location, dea.Date) As RollingPeapleVaccinated
-- , (RollingPeapleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- Order By 2,3

Select *
From PercentPopulationVaccinated
Order By 2,3