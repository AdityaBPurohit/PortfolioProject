Select *
From [Portfolio Project]..CovidDeaths$
where continent is not null
order by 3,4

--Select *
--From [Portfolio Project]..CovidVaccinations$
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project]..CovidDeaths$
where continent is not null
order by 1,2

-- Looking at total deaths VS total cases
-- Shows te likelihood of dying if your contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths$
where location like 'India'
and continent is not null
order by 1,2

-- Looking at total cases VS population
-- Shows what percentage of population got covid
Select location, date, population, total_cases, (total_cases/population)*100 as CasePercentage
from [Portfolio Project]..CovidDeaths$
where location like 'India'
and continent is not null
order by 1,2


-- Looking at countries with highest infection rate compared to population

Select location, population, max(total_cases) as HighestInfectionRate, max((total_cases/population))*100 as CasePercentage
from [Portfolio Project]..CovidDeaths$
where continent is not null
Group by location, population
order by CasePercentage desc

-- Showing Countries with Highest death count per population

Select location,  max(Cast (total_deaths as int)) as TotalDeathcount
from [Portfolio Project]..CovidDeaths$
where continent is not null
Group by location
order by TotalDeathcount desc

-- Lets break it down by continent

Select continent,  max(Cast (total_deaths as int)) as TotalDeathcount
from [Portfolio Project]..CovidDeaths$
where continent is not null
Group by continent
order by TotalDeathcount desc

-- Showing the continent with the highest death count per population 

Select continent,  max(Cast (total_deaths as int)) as TotalDeathcount
from [Portfolio Project]..CovidDeaths$
where continent is not null
Group by continent
order by TotalDeathcount desc


-- Global Numbers : Total New deaths per Total new Cases each day

Select Date, sum(new_cases) as TotalNewCases, sum(cast(new_deaths as int)) as TotalNewDeaths,sum(cast (new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths$
where continent is not null
Group by Date
order by 1,2

-- Global Numbers : over all Total New deaths per over all Total new Cases 

Select sum(new_cases) as TotalNewCases, sum(cast(new_deaths as int)) as TotalNewDeaths,sum(cast (new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths$
where continent is not null
order by 1,2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from [Portfolio Project]..CovidDeaths$ as Dea
join [Portfolio Project]..CovidVaccinations$ as Vac
on dea.location =vac.location
and dea.date=vac.date 
where dea.Continent is not null 
order by 1, 2,3


-- Looking at Total Population vs Rolling People Vaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as Rolling_People_Vaccinated
from [Portfolio Project]..CovidDeaths$ as Dea
join [Portfolio Project]..CovidVaccinations$ as Vac
on dea.location =vac.location
and dea.date=vac.date 
where dea.Continent is not null 
order by 1, 2,3


-- Use of CTE for Looking at Total Population vs Rolling People Vaccinated

With PopvsVac (continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as Rolling_People_Vaccinated
from [Portfolio Project]..CovidDeaths$ as Dea
join [Portfolio Project]..CovidVaccinations$ as Vac
on dea.location =vac.location
and dea.date=vac.date 
where dea.Continent is not null 
)
Select * , (Rolling_People_Vaccinated/Population)*100 as Percent_RollingPeopleVaccinated
from PopvsVac


-- Temp Table


Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255), 
Date datetime, 
population numeric,
new_vaccinations numeric,
Rolling_People_Vaccinated numeric,
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as Rolling_People_Vaccinated
from [Portfolio Project]..CovidDeaths$ as Dea
join [Portfolio Project]..CovidVaccinations$ as Vac
on dea.location =vac.location
and dea.date=vac.date 
where dea.Continent is not null 

Select * , (Rolling_People_Vaccinated/Population)*100 as Percent_RollingPeopleVaccinated
from #PercentPopulationVaccinated

-- Creating view to store data for later visualisation

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as Rolling_People_Vaccinated
from [Portfolio Project]..CovidDeaths$ as Dea
join [Portfolio Project]..CovidVaccinations$ as Vac
on dea.location =vac.location
and dea.date=vac.date 
where dea.Continent is not null 











