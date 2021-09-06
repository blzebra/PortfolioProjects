--SELECT *
--FROM PortfolioProject.dbo.CovidDeaths
--ORDER BY 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--ORDER BY 3,4

-- Select the Data that we are using

--Select Location, date, total_cases, new_cases, total_deaths
--From PortfolioProject.dbo.CovidDeaths
--ORDER BY 1,2

-- Looking at total cases vs total deaths
-- Shows likelyhood of dying if you contract covid in US

--Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--From PortfolioProject.dbo.CovidDeaths
--WHERE location LIKE '%states%'
--ORDER BY 1,2

-- Lookin at Total Cases vs Population

--Select Location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
--From PortfolioProject.dbo.[owid-covid-data]
--WHERE location LIKE '%states%'
--ORDER BY 1,2


-- Looking at countries with highest infection rate compared to population

--Select Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
--From PortfolioProject.dbo.[owid-covid-data]
----WHERE location LIKE '%states%'
--GROUP BY location, population
--ORDER BY PercentPopulationInfected DESC


-- Showing the countries with the Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.[owid-covid-data]
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc

-- Showing the continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.[owid-covid-data]
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.[owid-covid-data]
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc

-- global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.[owid-covid-data]
Where continent is not null
Order by 1,2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE Common Table Expression

With PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccinated)
as
(
Select dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingVaccinated/population)*100
from PopvsVac

-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingVaccinated/population)*100
from #PercentPopulationVaccinated
