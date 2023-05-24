Select *
From [Portfolio Project].dbo.CovidDeaths
Where continent is not null
Order by 3,4


--Select *
--From [Portfolio Project].dbo.CovidVaccinations
--Order by 3,4

--Select Data that we are going to be using


Select 
Location,
date,
total_cases,
New_cases,
Total_deaths,
population
From [Portfolio Project].dbo.CovidDeaths
Where continent is not null
Order by 1,2

-- Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

Select 
Location,
date,
total_cases,
Total_deaths,
(total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project].dbo.CovidDeaths
Where location like '%states%'
and Where continent is not null
Order by 1,2


--Looking at Total Cases vs Population
--Showw what percentage of population got Covid

Select 
Location,
date,
population,
total_cases,
(total_deaths/population)*100 as PercentPopulationInfected
From [Portfolio Project].dbo.CovidDeaths
Where location like '%states%'
Order by 1,2

--Looking at Cuntries with Highest Infection Rate compared to Population

Select 
Location,
population,
MAX(total_cases) as HighestInfectionCount,
MAX((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project].dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location, Population
Order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population

Select 
Location,
MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project].dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location
Order by TotalDeathCount desc

--Let's Break Things Down by Continent

Select 
continent,
MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project].dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

--Showing continent with the highest death count per population

Select 
continent,
MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project].dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

--Global Numbers

Select 
SUM (new_cases) as total_cases,
SUM(cast(new_deaths as int)) as Total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project].dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group by date
Order by 1,2

--Looking at Total Population vs Vaccinations

--CTE

With PopvsVac (continent, Location, Date, Population, New_vaccinations, RollingPeoleVaccinated)
as
(
Select
dea.continent,
dea.location,
dea.date,
dea.population, 
vac.new_vaccinations,
SUM(cONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date)
as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select*, (RollingPeoleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE

DROP Table if exists #PrecentPopulationVaccinated
Create Table #PrecentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeoleVaccinated numeric
)

Insert into #PrecentPopulationVaccinated
Select
dea.continent,
dea.location,
dea.date,
dea.population, 
vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date)
as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

Select*, (RollingPeoleVaccinated/Population)*100
From #PrecentPopulationVaccinated



--Creating View to store data for later visualizations

Create View PrecentPopulationVaccinated as
Select
dea.continent,
dea.location,
dea.date,
dea.population, 
vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date)
as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

select*
From PrecentPopulationVaccinated

Create View GlobalDeath as
Select 
SUM (new_cases) as total_cases,
SUM(cast(new_deaths as int)) as Total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project].dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group by date
--Order by 1,2

Select*
From GlobalDeath

Create View TotalDeathCount as
Select 
Location,
MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project].dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location
--Order by TotalDeathCount desc

Select*
From TotalDeathCount