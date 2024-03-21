select * from dbo.CovidDeaths
where continent is not null
order by 3,4

--select * from dbo.CovidVaccinations


select Location ,date, total_cases, new_cases, total_deaths, population
from dbo.CovidDeaths
where continent is not null
order by 1,2




--looking at total cases vs total deaths


select Location ,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from dbo.CovidDeaths
where location like '%india%'

order by 1,2






--looking at the total cases vs population
-- shows what percentage of people have got covid

select Location ,date, population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
from dbo.CovidDeaths
where location like '%india%'
order by 1,2



--looking at countries with higher infection rate compared to population


select Location , population, MAX(total_cases) AS HighestInfectionCount,  MAX(total_cases/population)*100 as  PercentPopulationInfected
from dbo.CovidDeaths
where continent is not null
--where location like '%india%'
Group by Location, population
order by PercentPopulationInfected desc



--Showing countries with highest death count per population


select Location ,  MAX(cast(total_deaths as int)) AS TotalDeathCounts
from dbo.CovidDeaths
where continent is not null
--where location like '%india%'
Group by Location
order by TotalDeathCounts desc


--LET'S BREAK THINGS DOWN BY CONTINENT





--showing continents with highest death count per population


select continent ,  MAX(cast(total_deaths as int)) AS TotalDeathCounts
from dbo.CovidDeaths
where continent is not null
--where location like '%india%'
Group by continent
order by TotalDeathCounts desc


--GLOBAL NUMBERS


select date, SUM(new_cases) as total_cases , SUM(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from dbo.CovidDeaths
--where location like '%india%'
where continent is not null
Group by date
order by 1,2


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
order by 2,3


--USE CTE
with PopvsVac (Continent, Location,date,population, New_Vaccinations, RollingPeopleVaccinated)
as

(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
dea.date) as RollingPeopleVaccinated
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
--order by 2,3
)

select*,(RollingPeopleVaccinated/population)*100
from PopvsVac




--TEMP TABLE

DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)


Insert into  #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
dea.date) as RollingPeopleVaccinated
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
--order by 2,3


select*,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated