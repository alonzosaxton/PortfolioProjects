select *
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 3, 4

--select *
--FROM PortfolioProject..CovidVaccinations
--order by 3, 4

-- SELECT Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows the liklihood of dying if you contract Covid in Canada

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%Canada%'
order by 1, 2

-- Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid

select location, date, population, total_cases, (total_cases/population)*100 as CasePercentage
FROM PortfolioProject..CovidDeaths
--Where location like '%Canada%'
order by 1, 2

-- Looking at Countries with Highest Infection Rate compared to Population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%Canada%'
Group by location, population
order by 4 desc


-- Showing Countries with Highest Death Count per Population

select location, population, max(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%Canada%'
where Continent is not null
Group by location, population
order by 3 desc

-- Let's break things down by continent
-- Showing continent with the Highest Death Count

select location, max(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%Canada%'
where Continent is null
Group by location
order by TotalDeathCount desc

-- GLOBAL NUMBERS

select sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where location like '%Canada%'
where continent is not null
--group by date
order by 1, 2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- Temp Table
Drop Table if exists #PercentPopulationVaccinated 
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
	ON dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated





-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select *
From PercentPopulationVaccinated


Create View CanadaCasePercentage as
select location, date, population, total_cases, (total_cases/population)*100 as CasePercentage
FROM PortfolioProject..CovidDeaths
Where location like '%Canada%'
--order by 1, 2

Select *
From CanadaCasePercentage

Create View HighestInfectionRate as
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Group by location, population
--order by 4 desc

Select *
From HighestInfectionRate

Create View HighestDeathCountPerCountry as
select location, population, max(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%Canada%'
where Continent is not null
Group by location, population
--order by 3 desc

Select *
From HighestDeathCountPerCountry
