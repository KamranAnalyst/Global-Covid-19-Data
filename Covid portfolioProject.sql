
--select data that we are gonna use frequently.

select *
from PortfolioProject..coviddeaths

select location, date,total_cases,new_cases,total_deaths,population
from PortfolioProject..coviddeaths
order by 1,2


--EXEC sp_help 'dbo.coviddeaths'
--ALTER TABLE dbo.coviddeaths
--ALTER COLUMN total_cases_per_million FLOAT

--Looking at total cases vs total deaths
--What percenatge % of ppl died having Covid-19

SELECT location,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_Percentage
from PortfolioProject..coviddeaths
WHERE location LIKE '%india%'
order by 1,2

-- Looking at total ppl VS total Cases
--What PPL (%) have got Covid-19

Select location,date,population,total_cases,(total_cases/population)*100 AS PercentPPLInfected
from PortfolioProject..coviddeaths
where location LIKE '%india%'
order by 1,2

--Looking at countries having highest infestion rate compared to total PPL.

Select location,population,MAX(total_cases) high_infection,max((total_cases/population))*100 AS PercentPPLInfected
from PortfolioProject..coviddeaths
group by location,population
order by PercentPPLInfected DESC

--countries with highest death count per PPL

select location,population,MAX(total_deaths) MaxDeath,MAX(total_deaths/population)*100 AS Max_Death_PPL_PERCENTAGE
from PortfolioProject..coviddeaths
WHERE continent is not null
GROUP BY location,population
ORDER BY MaxDeath DESC

--Both syntax Works--

select location,MAX(total_deaths) MaxDeath
from PortfolioProject..coviddeaths
WHERE continent is not null
group by location
order by MaxDeath DESC

-- Explore by Continent 

select location,MAX(total_deaths) MaxDeath
from PortfolioProject..coviddeaths
WHERE continent is null
group by location
order by MaxDeath DESC                          --includes only continents


select location,MAX(total_deaths) MaxDeath
from PortfolioProject..coviddeaths
WHERE continent is null
AND location not in ('world','high income','upper middle income','lower middle income','european union','lower middle income')
group by location
order by MaxDeath DESC                      --includes continents & all countries



select location,MAX(total_deaths) MaxDeath
from PortfolioProject..coviddeaths
WHERE continent is not null
group by location
order by MaxDeath DESC                   ---------Includes only COUNTRIES----------

--Exploring continents with highest death rates--

select location,MAX(total_deaths) MaxDeath
from PortfolioProject..coviddeaths
WHERE continent is null
group by location
order by MaxDeath DESC                                   --continents & high income

-- Explore continents with the highest death count per population.

select continent,max(total_deaths) maxdths
from PortfolioProject..coviddeaths
where continent is not null
group by continent
order by maxdths desc 

--Global Survey-- Across The World--world deaths per DAY

select date,sum(new_cases) AS cases_total,sum(new_deaths) AS deaths_total ,sum(new_deaths)/sum(NULLIF(new_cases,0))*100 DeathPercent
from PortfolioProject..coviddeaths
WHERE continent is not null
group by date,new_cases,new_deaths
order by date asc

-- World death percentage--

select sum(new_cases) AS cases_total,sum(new_deaths) AS deaths_total ,sum(new_deaths)/sum(NULLIF(new_cases,0))*100 DeathPercent
from PortfolioProject..coviddeaths
WHERE continent is not null

--Looking At Total PPL vs Vaccinated PPL PERCENT 

WITH popvsvac (continent,location,date,population,new_vaccinations,RollingCountVaccitation)
AS(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) RollingCountVaccitation
from PortfolioProject..covidvac vac
join PortfolioProject..coviddeaths dea
ON vac.location = dea.location
and vac.date = dea.date
where dea.continent is not null
group by dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
--order by 1,2,3
)
                           ----------OR We can use Temp Tables------

---- Use case of CTE---
SELECT *,RollingCountVaccitation/population*100 AS PercentVaccantedPPL
FROM popvsvac
group by continent,location,date,population,new_vaccinations,RollingCountVaccitation

------Temp Tables----
DROP TABLE IF EXISTS #percentpplvac
Create Table #percentpplvac
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population float,
new_vaccinations nvarchar(255),
RollingCountVaccitation float
)
insert into #percentpplvac
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) RollingCountVaccitation
from PortfolioProject..covidvac vac
join PortfolioProject..coviddeaths dea
ON vac.location = dea.location
and vac.date = dea.date
where dea.continent is not null

select *, (RollingCountVaccitation/population)*100 AS PerCentPPLVac
from #percentpplvac

---View table--

CREATE VIEW percentpplvac AS
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,--MAX(RollingCountVaccitation) / dea.population *100,
SUM(CONVERT(bigint,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) RollingCountVaccitation
from PortfolioProject..covidvac vac
join PortfolioProject..coviddeaths dea
ON vac.location = dea.location
and vac.date = dea.date
where dea.continent is not null

                                    select *
                                    from percentpplvac     ---- percentage of ppl vac vs of total ppl (view in %
								
CREATE VIEW GlobalDeathPercent AS 
select sum(new_cases) AS cases_total,sum(new_deaths) AS deaths_total ,sum(new_deaths)/sum(NULLIF(new_cases,0))*100 DeathPercent
from PortfolioProject..coviddeaths
WHERE continent is not null

                                SELECT *
								FROM GlobalDeathPercent ---------------Global Death Percentage

CREATE VIEW DeathPercentAsDate AS
select date,sum(new_cases) AS cases_total,sum(new_deaths) AS deaths_total ,sum(new_deaths)/sum(NULLIF(new_cases,0))*100 DeathPercent
from PortfolioProject..coviddeaths
WHERE continent is not null
group by date,new_cases,new_deaths
                                        SELECT *
										FROM DeathPercentAsDate  ------Global Death Rate % as per day/date
CREATE VIEW MaxDeathsContinents AS                        
select continent,max(total_deaths) maxdths
from PortfolioProject..coviddeaths
where continent is not null
group by continent
                                                SELECT *
												FROM MaxDeathsContinents  ----Global Deaths count per Contients
CREATE VIEW DeathsContWorld AS
select location,MAX(total_deaths) MaxDeath
from PortfolioProject..coviddeaths
--WHERE continent is  null
group by location

                                               SELECT *
											   FROM DeathsContWorld
											   order by MaxDeath Desc  --------------Continents & Countries Deaths Count

CREATE VIEW InfectionRateper AS
Select location,population,MAX(total_cases) high_infection,max((total_cases/population))*100 AS PercentPPLInfected
from PortfolioProject..coviddeaths
group by location,population
 
                                                SELECT *
												FROM InfectionRateper
												order by PercentPPLInfected DESC  -----------Highest Infection Rate In The World (Contries)


Select location,population,date,MAX(total_cases) high_infection,max((total_cases/population))*100 AS PercentPPLInfected
from PortfolioProject..coviddeaths
group by location,population,date
order by PercentPPLInfected desc