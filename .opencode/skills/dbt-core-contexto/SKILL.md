---
name: dbt-core-contexto
description: Usar este skill cuando se trabaja en tareas relacionadas a proyectos dbt Core. Provee contexto sobre convenciones, estructura de proyecto y comandos frecuentes. Activar cuando se pida escribir, revisar o debuggear modelos dbt, macros o tests.
---

# Skill: dbt Core

## Comandos esenciales

```bash
dbt run                          # Correr todos los modelos
dbt run --select stg_pedidos     # Correr un modelo específico
dbt run --select stg_pedidos+    # Modelo + sus dependientes
dbt run --select +fct_pedidos    # Modelo + sus dependencias
dbt test --select stg_pedidos    # Testear un modelo
dbt compile --select stg_pedidos # Compilar sin ejecutar (debug)
dbt docs generate && dbt docs serve  # Documentación visual
dbt source freshness             # Verificar frescura de fuentes
dbt deps                         # Instalar paquetes
```

## Refs y sources

```sql
SELECT * FROM {{ source('esquema_crudo', 'pedidos') }}  -- tabla fuente
SELECT * FROM {{ ref('stg_pedidos') }}                   -- modelo dbt
```

## Modelo incremental

```sql
{{ config(materialized='incremental', unique_key='pedido_id') }}

SELECT pedido_id, cliente_id, fecha_pedido, monto_total
FROM {{ ref('int_pedidos_enriquecidos') }}

{% if is_incremental() %}
  WHERE fecha_pedido > (SELECT MAX(fecha_pedido) FROM {{ this }})
{% endif %}
```

## Reglas para el agente

1. Siempre `{{ ref() }}` — nunca hardcodear esquema.tabla
2. Sugerir materialización según volumen y frecuencia
3. En incrementales, siempre incluir el guard `is_incremental()`
4. Tests de `unique` + `not_null` en claves primarias por defecto
5. Usar `--select` para correr solo lo necesario
6. Antes de `dbt run`, hacer `dbt compile` para revisar el SQL generado