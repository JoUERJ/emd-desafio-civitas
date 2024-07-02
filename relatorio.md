# Desafio CIVITAS
#### Solução - João Victor Monteiro de Macedo | Email: joaovicmonteiro.m@gmail.com

## Introdução

Este documento detalha a solução para o desafio técnico da Prefeitura do Rio de Janeiro utilizando dados de leituras de radar.

## Metodologia

### Análise Exploratória dos Dados

1. **Verificação da estrutura da tabela**
   ```sql
   SELECT *
   FROM `rj-cetrio.desafio.readings_2024_06`
   LIMIT 10;
   ```

2. **Contagem do número total de registros**
   ```sql
   SELECT COUNT(*) as total_registros
   FROM `rj-cetrio.desafio.readings_2024_06`;
   ```

3. **Distribuição de datas das leituras**
   ```sql
   SELECT 
     DATE(datahora) as data, 
     COUNT(*) as quantidade
   FROM `rj-cetrio.desafio.readings_2024_06`
   GROUP BY DATE(datahora)
   ORDER BY data;
   ```

4. **Quantidade de leituras por radar**
   ```sql
   SELECT 
     camera_numero, 
     COUNT(*) as quantidade
   FROM `rj-cetrio.desafio.readings_2024_06`
   GROUP BY camera_numero
   ORDER BY quantidade DESC;
   ```

5. **Distribuição de tipos de veículos**
   ```sql
   SELECT 
     tipoveiculo, 
     COUNT(*) as quantidade
   FROM `rj-cetrio.desafio.readings_2024_06`
   GROUP BY tipoveiculo
   ORDER BY quantidade DESC;
   ```

6. **Detecção de possíveis inconsistências**
   ```sql
   SELECT *
   FROM `rj-cetrio.desafio.readings_2024_06`
   WHERE datahora > datahora_captura;
   ```

### Identificação de Placas Possivelmente Clonadas

```sql
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
```

### Resultados

#### Contagem do Número Total de Registros
- **Total de registros:** 500

#### Distribuição de Datas das Leituras
- A distribuição das datas das leituras ao longo do mês de junho de 2024 é relativamente uniforme. Os dados estão distribuídos entre os dias 6 e 13 de junho, com quantidades de leituras variando diariamente.

#### Quantidade de Leituras por Radar
- O radar com o maior número de leituras é identificado pelo código `AGkqcnSxWQ==`, com 179 registros.
- Outros radares com um número significativo de leituras incluem `BLym/2aTMw==` com 64 registros e `Aq74aBWLTw==` com 54 registros.

#### Distribuição de Tipos de Veículos
- Todos os registros de leitura de radar estão associados ao tipo de veículo identificado pelo código `AxzAA36BbQ==`.

#### Detecção de Possíveis Inconsistências
- Algumas inconsistências foram encontradas onde a `datahora` das leituras é maior que a `datahora_captura`. Esses registros podem indicar problemas no sistema de captura ou erros de processamento dos dados.

#### Identificação de Placas Possivelmente Clonadas
- Foram identificados casos de possíveis clonagens de placas, onde um veículo foi registrado por diferentes radares em um intervalo de tempo inferior a 10 minutos. Um exemplo é a placa `uDt1+k2I52leKxbQHX7IXB0=` que foi registrada pelo radar `AGkqcnSxWQ==` às 16:34:30 e pelo radar `Aq74aBWLTw==` às 16:31:45 do mesmo dia.

### Conclusão

A análise dos dados de leitura de radar forneceu vários insights importantes. A distribuição das leituras ao longo do mês de junho foi uniforme, e alguns radares capturaram significativamente mais dados do que outros. Todos os registros foram de um tipo específico de veículo.

A análise identificou inconsistências entre os horários de captura e os horários das leituras, que podem indicar problemas no sistema de captura. Além disso, foram identificados possíveis casos de clonagem de placas, que requerem investigação adicional para confirmar se houve fraude.

Esses resultados fornecem uma base sólida para ações futuras, como a otimização da distribuição de radares e a investigação de possíveis fraudes de clonagem de placas. A Prefeitura do Rio de Janeiro pode usar essas informações para melhorar a eficiência e a precisão de seu sistema de monitoramento de tráfego.