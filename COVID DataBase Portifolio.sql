--SELECT*
--FROM ProjetoDePortifolio..CovidVaccinations
--ORDER BY 3,4

-- Selecionar os dados que iremos utilizar.

--SELECT Location, date, total_cases, new_cases, total_deaths, population
--FROM ProjetoDePortifolio..CovidDeaths
--ORDER BY 1,2

--Estamos comaprando os casos totais com o total de mortes. 
--Mostra a probabilidade de morrer se você contrair covid em seu país 

SELECT Location, date, total_cases, total_deaths, CAST (total_deaths AS FLOAT)/ (CAST(total_cases AS FLOAT)) * 100 AS DeathPercentage
FROM ProjetoDePortifolio..CovidDeaths
WHERE Location like '%Brazil%'
ORDER BY 1,2

--Comparando o total de casos com a população
--Porcentagem da população que se infectou com Covid
SELECT Location, date, total_cases, population, CAST(total_cases AS FLOAT)/ (CAST(populationAS FLOAT)) * 100 AS PercentPopulationInfected
FROM ProjetoDePortifolio..CovidDeaths
WHERE Location like '%Brazil%'
ORDER BY 1,2

--Encontrando a maior taxa de infecção nos países.
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)) * 100) AS PercentPopulationInfected
FROM ProjetoDePortifolio..CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc

--Os Países com a maior quantidade de mortos.
SELECT Location, MAX(total_deaths) as TotalDeathCount
FROM ProjetoDePortifolio..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc 

--Os continentes com a maior quantidade de mortos.
SELECT Location, MAX(total_deaths) as TotalDeathCount
FROM ProjetoDePortifolio..CovidDeaths
WHERE continent is null
GROUP BY Location
ORDER BY TotalDeathCount desc 

--Os valores globais
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/ SUM(new_cases) * 100 AS DeathPercentage
FROM ProjetoDePortifolio..CovidDeaths
WHERE continent is not null 
GROUP BY date
ORDER BY date


--Poulação total / Vacinados.
CREATE VIEW PercentpopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
FROM ProjetoDePortifolio..CovidDeaths dea
Join ProjetoDePortifolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null 

SELECT * 
FROM PercentpopulationVaccinated