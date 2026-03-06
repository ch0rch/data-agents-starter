# Overview del Proyecto de Datos

> **Editá este archivo con los detalles de tu proyecto real antes de empezar.**

## ¿Qué es este proyecto?

[Describí brevemente el negocio y qué problema de datos resuelve este proyecto]

Ejemplo:
> Este proyecto centraliza y transforma los datos operativos de la plataforma de e-commerce. El objetivo es tener una capa analítica limpia que permita responder preguntas de negocio sobre pedidos, clientes y productos sin tocar las bases de datos de producción.

## Stack técnico

- **Ingesta:** Apache Airflow (versión X.X)
- **Warehouse:** [PostgreSQL / BigQuery / Snowflake / DuckDB]
- **Transformaciones:** dbt Core (versión X.X)
- **BI / Consumo:** [Metabase / Looker / Tableau / etc.]

## Entornos

| Entorno | Esquema warehouse | Uso |
|---------|------------------|-----|
| dev | `dev_[tu_nombre]` | Desarrollo y pruebas locales |
| staging | `staging` | QA antes de producción |
| prod | `analytics` | Producción, consumido por BI |

## Métricas clave del negocio

[Listá las 5-10 métricas más importantes que este proyecto debe poder responder]

- Ejemplo: Pedidos por día / semana / mes
- Ejemplo: Revenue total y por categoría
- Ejemplo: Tasa de cancelación
- Ejemplo: Clientes nuevos vs recurrentes

## Dominio de datos principal

[Describí brevemente los dominios o áreas de negocio que cubre el proyecto]

- **Pedidos:** ciclo de vida completo de una orden
- **Clientes:** registro y comportamiento de usuarios
- **Productos:** catálogo e inventario
- **Pagos:** transacciones y métodos de pago
