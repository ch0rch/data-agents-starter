# Data Engineering Agents

Este es el punto de entrada al workspace multiagente. **Mencioná `@AGENTS` para activar el orquestador.**

## Cómo usar este workspace

1. **Describí tu tarea** - Ej: "Crear un modelo de clientes activos" o "Mostrame las ventas del último mes"
2. **El orquestador (@AGENTS) analiza tu pedido** y lo delega al agente especializado correcto
3. **El agente ejecuta la tarea** y escribe el resultado en `_inbox/`

## Agentes disponibles

| Agente | Qué hace | Ejemplo de pedido |
|--------|----------|-------------------|
| `@dbt-agent` | Modelos SQL, tests, macros | "Crear modelo staging de usuarios" |
| `@airflow-agent` | DAGs y orquestación | "Crear DAG para cargar datos diarios" |
| `@analytics-agent` | Consultas y métricas | "Cuántos pedidos tuvimos ayer?" |
| `@docs-agent` | Documentación automática | "Generar schema.yml para el proyecto" |

## Contexto del proyecto

Antes de empezar, revisá:
- `knowledge/overview.md` - Descripción general del proyecto
- `knowledge/fuentes.md` - Catálogo de tablas fuente
- `knowledge/convenciones.md` - Reglas de nomenclatura SQL

---

**Para empezar:** Mencioná `@AGENTS` y describí qué necesitás.
