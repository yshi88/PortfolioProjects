Select*
From COVID19..CovidDeaths
Where continent is not null
Order by 3,4

--Select*
--From COVID19..CovidVaccinations
--order by 3,4

--Select data one of the two from above

Select location, date, total_cases, new_cases, total_deaths, population 
Where continent is not null
From COVID19..CovidDeaths
Order by 1,2

--Looking at Total Cases vs Total Deaths 
--demonstrate the likelihood of death if you contract covid in your country
Select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From COVID19..CovidDeaths
Where location like '%states%'
and continent is not null
Order by 1,2

--Looking at Total Cases vs Population
--demonstrate the percentage of population got COVID 
Select location, date, total_cases,population,(total_cases/population)*100 as COVIDCasesPercentage
From COVID19..CovidDeaths
Where location like '%states%'
and continent is not null
Order by 1,2

--looking at country with highest COVID cases compared to population 
Select location, population, MAX(total_cases) as HighestInfectionCount,MAX(total_cases/population)*100 as PopulationInfectedPercentage
From COVID19..CovidDeaths
Where continent is not null
Group by Location, population
Order by PopulationInfectedPercentage desc

--Showing Countries with highest death count  
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From COVID19..CovidDeaths
Where continent is not null
Group by Location
Order by TotalDeathCount desc


--Showing Continents with total death count
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From COVID19..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc

--Showing COVID death percentage across the world
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From COVID19..CovidDeaths
Where continent is not null
Order by 1,2

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From COVID19..CovidDeaths dea
Join COVID19..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

--looking at the total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(int,vac.new_vaccinations)) Over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
From COVID19..CovidDeaths dea
Join COVID19..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

--USE CTE

With PopvsVac (Continent,Location,Date,Population,New_vaccinations,RollingPeopleVaccinated)

as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(int,vac.new_vaccinations)) Over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
From COVID19..CovidDeaths dea
Join COVID19..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select*, (RollingPeopleVaccinated/population)*100
From PopvsVac

--Temp Table

DROP TABLE if exists #PercentPopulationVaccinated
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
,SUM(Convert(int,vac.new_vaccinations)) Over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
From COVID19..CovidDeaths dea
Join COVID19..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations 

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(int,vac.new_vaccinations)) Over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
From COVID19..CovidDeaths dea
Join COVID19..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated
