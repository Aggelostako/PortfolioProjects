Select * 
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select Data that Im going to use

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
Order by 1,2

--Looking at Total cases vs Total deaths
--Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/ total_cases)* 100 as DeathPercentage
From PortfolioProject..CovidDeaths
where Location like 'B%il'
and continent is not null
Order by 1,2	


--Looking at Total Cases vs Population
--Shows What percentage of population got COVID

Select Location, date, Population, total_cases, (total_cases/ population)* 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Order by 1,2	


--Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))* 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where Location like 'B%il'
Group by Location, Population
Order by PercentPopulationInfected desc



--Showing Countries with the Highest Death Count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where Location like 'B%il'
where continent is not null
Group by Location
Order by TotalDeathCount desc


--Showing continents with the Highest death count per population	


Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where Location like 'B%il'
where continent is not null
Group by continent
Order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where Location like 'B%il'
where continent is not null
and new_cases <> 0
Group By date
Order by 1,2


Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where Location like 'B%il'
where continent is not null
and new_cases <> 0
--Group By date
Order by 1,2


--Looking the share of people fully vaccinated per population 


Select dea.continent, dea.location, dea.date, dea.population,vac.people_fully_vaccinated
,MAX(cast(vac.people_fully_vaccinated as bigint)) Over (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleFullyVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3



--USE CTE


With PopvsFullyVac(continent, location, date, population, people_fully_vaccinated, RollingPeopleFullyVaccinated)
AS
(Select dea.continent, dea.location, dea.date, dea.population,vac.people_fully_vaccinated
,MAX(cast(vac.people_fully_vaccinated as bigint)) Over (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleFullyVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)

Select * ,(RollingPeopleFullyVaccinated/population)*100 as PercentOfpplFullyVaccinated
From PopvsFullyVac
Where location like '%ria'




--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,
dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3




--USE CTE

With PopvsVac (continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,
dea.Date) as RollingPeopleVaccinated
--,
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select * ,(RollingPeopleVaccinated/population)*100 as PercentPPLvaccinated
From PopvsVac



-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,
dea.Date) as RollingPeopleVaccinated
--,
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select * ,(RollingPeopleVaccinated/population)*100 AS PercentPPLvaccinated
From #PercentPopulationVaccinated



--Creating View to store data for later visualizations


Drop view PercentPopulationVaccinated
Create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,
dea.Date) as RollingPeopleVaccinated
--,
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3


Select * 
From PercentPopulationVaccinated
