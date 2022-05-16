Select * 
from Portofolio..CovidDeaths
order by location

select *
from portofolio..CovidVacc
where location= 'Egypt'
order by location

----------------------------------------------------------------------------------------------------------------------
--Total cases vs Total Deaths worldwide 
Select location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portofolio..CovidDeaths
Where continent is not null
Order by 1,2

----------------------------------------------------------------------------------------------------------------------
--Total cases vs Total Deaths in Egypt and possibilty to die from it in the country
Select location, Max(total_cases), Max(total_deaths), (Max(total_deaths)/Max(total_cases))*100 as DeathPercentage
From Portofolio..CovidDeaths
where location = 'Egypt'
group by location

----------------------------------------------------------------------------------------------------------------------
--Percentage of Covid Cases per population
Select location, date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
From Portofolio..CovidDeaths
where location = 'Egypt'
Order by 1,2

----------------------------------------------------------------------------------------------------------------------
--Highest Covid infection rate per population worldwide
Select location, Population, Max(total_cases) as HighestInfectionCount, MAX((total_cases)/population)*100 as InfectionPercentage
From Portofolio..CovidDeaths
Where continent is not null
Group by location, population
Order by InfectionPercentage desc

----------------------------------------------------------------------------------------------------------------------
--Highest Covid death rate per population worldwide
Select location, Population, Max(total_deaths) as HighestDeathCount, MAX((total_deaths)/population)*100 as DeathPercentage
From Portofolio..CovidDeaths
Where continent is not null
Group by location, population
Order by DeathPercentage desc

----------------------------------------------------------------------------------------------------------------------
--Highest Death count by country
Select Location, MAX(Cast(total_deaths as int)) as Deathcount
From Portofolio..CovidDeaths
Where continent is not null
Group by location
Order by Deathcount desc

----------------------------------------------------------------------------------------------------------------------
--Highest Death count by continent
Select iso_code, location, MAX(Cast(total_deaths as int)) as Deathcount
From Portofolio..CovidDeaths
Where continent is null AND NOT iso_code ='OWID_UMC' AND NOT iso_code = 'OWID_HIC' AND NOT iso_code = 'OWID_LMC' AND NOT iso_code = 'OWID_LIC' AND NOT iso_code = 'OWID_INT'
Group by location, iso_code
Order by Deathcount desc

----------------------------------------------------------------------------------------------------------------------
--Highest Death count by continent
Select iso_code, location, MAX(Cast(total_deaths as int)) as Deathcount
From Portofolio..CovidDeaths
Where continent is null AND NOT iso_code ='OWID_WRL' AND NOT iso_code = 'OWID_EUR' AND NOT iso_code = 'OWID_NAM' AND NOT iso_code = 'OWID_ASI' AND NOT iso_code = 'OWID_SAM' AND NOT iso_code ='OWID_EUN' AND NOT iso_code = 'OWID_AFR' AND NOT iso_code = 'OWID_OCE' AND NOT iso_code = 'OWID_INT'
Group by location, iso_code
Order by Deathcount desc

----------------------------------------------------------------------------------------------------------------------
--Egypt's Death count and infection count
Select Location, MAX(Cast(total_deaths as int)) as Deathcount, MAX(Cast(total_cases as int)) as InfectionCount
From Portofolio..CovidDeaths
Where location = 'Egypt'
Group by location
Order by Deathcount desc

----------------------------------------------------------------------------------------------------------------------
--Global numbers for COVID each day since COVID started
Select date, SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100 as TotalDeathsPercentage
From Portofolio..CovidDeaths
where continent is not null
Group by date
order by date

----------------------------------------------------------------------------------------------------------------------
--Covid Death Percentage
Select SUM(new_cases)  as TotalCases , SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as TotalDeathsPercentage
From Portofolio..CovidDeaths
where continent is not null

----------------------------------------------------------------------------------------------------------------------
--Joining two tables
Select *
From Portofolio..CovidDeaths dth
Join Portofolio..CovidVacc vac
on dth.location  = vac.location
And dth.date = vac.date 

----------------------------------------------------------------------------------------------------------------------
--Each country and the cumalative vaccination number for each date
Select dth.continent, dth.location , dth.date, dth.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER(partition by dth.location ORDER BY dth.location, dth.date) as CumulatedVaccinations
From Portofolio..CovidDeaths dth
Join Portofolio..CovidVacc vac
on dth.location  = vac.location
And dth.date = vac.date 
where dth.continent is not null
order by 2,3

----------------------------------------------------------------------------------------------------------------------
--Common Table Expression 

With PopxVacc( continent, location, date, population, New_vaccinations, CumulatedVaccinations)
as (
Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations))
OVER(Partition by dth.location Order by dth.location, dth.date) as CumulatedVaccinations
From Portofolio..CovidDeaths dth
Join Portofolio..CovidVacc vac
on dth.location = vac.location
and dth.date = vac.date
where dth.continent is not null
)
Select *, (CumulatedVaccinations/population)*100 as VaccinatedPopulationPercentage
from PopxVacc

----------------------------------------------------------------------------------------------------------------------
--Creating table

Create table #VaccinatedPopulationPercentage
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CumulatedVaccinations numeric)

----------------------------------------------------------------------------------------------------------------------
--Inserting into a table
Insert into #VaccinatedPopulationPercentage
Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations))
OVER(Partition by dth.location Order by dth.location, dth.date) as CumulatedVaccinations
From Portofolio..CovidDeaths dth
Join Portofolio..CovidVacc vac
on dth.location = vac.location
and dth.date = vac.date
where dth.continent is not null

----------------------------------------------------------------------------------------------------------------------
--showing results from a created table
Select *, (CumulatedVaccinations/population)*100 as VaccinatedPopulationPercentage
from #VaccinatedPopulationPercentage

----------------------------------------------------------------------------------------------------------------------
--dropping a table

Drop table if exists #VaccinatedPopulationPercentage 


----------------------------------------------------------------------------------------------------------------------
--Creating views for visualizations
----------------------------------------------------------------------------------------------------------------------
create VIEW CasesxDeathsperCountry  as
Select location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portofolio..CovidDeaths
Where continent is not null

Create View COVIDDeathPercentage as
Select SUM(new_cases)  as TotalCases , SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as TotalDeathsPercentage
From Portofolio..CovidDeaths
where continent is not null

Select location, population,Max(convert(bigint,total_deaths)) as HighestInfectionCount, MAX((convert(bigint,total_deaths))/population)*100 as InfectionPercentage
From Portofolio..CovidDeaths
Where continent is not null
group by location, population
order by 3 desc


Select location, Population, Max(total_cases) as HighestInfectionCount, MAX((total_cases)/population)*100 as InfectionPercentage
From Portofolio..CovidDeaths
Where continent is not null
Group by location, population
Order by InfectionPercentage desc


Create view TotalDeathsInRegions as
Select location, SUM(Convert(BIGINT, total_deaths)) as TotalDeathCount
from Portofolio..CovidDeaths
where continent is null 
and location not in('World', 'European Union', 'International', 'Lower middle income', 'Low income', 'Upper middle income', 'High income')
group by location


create view InfectionRateVSPopulation as
Select location, Population, Max(total_cases) as HighestInfectionCount, MAX((total_cases)/population)*100 as InfectionPercentage
From Portofolio..CovidDeaths
Where continent is not null 
and total_cases is not null 
and location not in('World', 'European Union', 'International', 'Lower middle income', 'Low income', 'Upper middle income', 'High income')
Group by location, population

drop view InfectionRateVSPopulationDated 
Select location, Population, date, Max(total_cases) as HighestInfectionCount, MAX((total_cases)/population)*100 as InfectionPercentage
From Portofolio..CovidDeaths
Where continent is not null
and location not in('World', 'European Union', 'International', 'Lower middle income', 'Low income', 'Upper middle income', 'High income')
Group by location, population, date

CREATE view InfectionRateVSPopulationDated AS
Select location, Population, date, Max(total_cases) as HighestInfectionCount, MAX((total_cases)/population)*100 as InfectionPercentage
From Portofolio..CovidDeaths
Where continent is not null
and location in ('Egypt', 'United States', 'Faeroe Islands', 'Denmark', 'Cyprus', 'Andorra', 'Gibraltar', 'France')
Group by location, population, date


Create View VaccinationsInfo as
With PopxVacc( continent, location, date, population, New_vaccinations, CumulatedVaccinations)
as (
Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations))
OVER(Partition by dth.location Order by dth.location, dth.date) as CumulatedVaccinations
From Portofolio..CovidDeaths dth
Join Portofolio..CovidVacc vac
on dth.location = vac.location
and dth.date = vac.date
where dth.continent is not null
)
Select *, (CumulatedVaccinations/population)*100 as VaccinatedPopulationPercentage
from PopxVacc


Select dth.continent, dth.location, dth.date, dth.population, max(vac.total_vaccinations) as CumulatedVaccinatedPeople
from Portofolio..CovidDeaths dth
Join Portofolio..CovidVacc vac
on dth.location = vac.location
and dth.date = vac.date
where dth.continent is not null
group by dth.continent, dth.location, dth.date, dth.population
order by 1,2,3

Select dth.location, dth.Population, Max(dth.total_cases) as HighestInfectionCount, max(vac.total_vaccinations) as TotalVaccines, MAX((dth.total_cases)/population)*100 as InfectionPercentage, MAX((vac.total_vaccinations)/population)*100 as VaccinatedPercentage
From Portofolio..CovidDeaths dth
Join Portofolio..CovidVacc vac
on dth.location = vac.location
and dth.date = vac.date
Where dth.continent is not null 
and dth.total_cases is not null 
and dth.location not in('World', 'European Union', 'International', 'Lower middle income', 'Low income', 'Upper middle income', 'High income')
Group by dth.location, dth.population
order by VaccinatedPercentage desc

Select dth.location, dth.Population, dth.date, Max(dth.total_cases) as HighestInfectionCount, max(vac.total_vaccinations) as TotalVaccines, MAX((dth.total_cases)/population)*100 as InfectionPercentage, MAX((vac.total_vaccinations)/population)*100 as VaccinatedPercentage
From Portofolio..CovidDeaths dth
Join Portofolio..CovidVacc vac
on dth.location = vac.location
and dth.date = vac.date
Where dth.continent is not null 
and dth.total_cases is not null 
and dth.location not in('World', 'European Union', 'International', 'Lower middle income', 'Low income', 'Upper middle income', 'High income')
Group by dth.location, dth.population, dth.date
order by dth.location

