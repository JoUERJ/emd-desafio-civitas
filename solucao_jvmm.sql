-- Solução | João Victor Monteiro de Macedo | Email: joaovicmonteiro.m@gmail.com --

-- Análise Exploratória dos Dados --
-- 1. Verificar a estrutura da Tabela

SELECT *
FROM `rj-cetrio.desafio.readings_2024_06`
LIMIT 10;

-- 2. Contar o número total de registros

SELECT COUNT(*) as total_registros
FROM `rj-cetrio.desafio.readings_2024_06`;

-- 3. Verificar a distribuição de datas das leituras

SELECT 
  DATE(datahora) as data, 
  COUNT(*) as quantidade
FROM `rj-cetrio.desafio.readings_2024_06`
GROUP BY DATE(datahora)
ORDER BY data;

-- 4. Identificar a quantidade de leituras por radar

SELECT 
  camera_numero, 
  COUNT(*) as quantidade
FROM `rj-cetrio.desafio.readings_2024_06`
GROUP BY camera_numero
ORDER BY quantidade DESC;

-- 5. Verificar a distribuição de tipos de veículos

SELECT 
  tipoveiculo, 
  COUNT(*) as quantidade
FROM `rj-cetrio.desafio.readings_2024_06`
GROUP BY tipoveiculo
ORDER BY quantidade DESC;

-- 6. Detectar possíveis inconsistências (datas invertidas, por exemplo)

SELECT *
FROM `rj-cetrio.desafio.readings_2024_06`
WHERE datahora > datahora_captura;

-- Identificação de Placas Possivelmente Clonadas --

WITH placa_diferentes_locais AS (
  SELECT 
    placa,
    datahora,
    camera_numero,
    camera_latitude,
    camera_longitude,
    LAG(camera_numero) OVER (PARTITION BY placa ORDER BY datahora) as last_camera_numero,
    LAG(datahora) OVER (PARTITION BY placa ORDER BY datahora) as last_datahora,
    LAG(camera_latitude) OVER (PARTITION BY placa ORDER BY datahora) as last_camera_latitude,
    LAG(camera_longitude) OVER (PARTITION BY placa ORDER BY datahora) as last_camera_longitude
  FROM `rj-cetrio.desafio.readings_2024_06`
),
possiveis_clonagens AS (
  SELECT 
    placa,
    datahora,
    last_datahora,
    camera_numero,
    last_camera_numero,
    camera_latitude,
    last_camera_latitude,
    camera_longitude,
    last_camera_longitude
  FROM placa_diferentes_locais
  WHERE last_camera_numero IS NOT NULL
  AND camera_numero != last_camera_numero
  AND TIMESTAMP_DIFF(datahora, last_datahora, MINUTE) < 10  -- Verifica leituras em menos de 10 minutos
)
SELECT *
FROM possiveis_clonagens;
