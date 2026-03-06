# Catálogo de Tablas Fuente

> **Editá este archivo con las tablas reales de tu warehouse.**

Las fuentes se declaran en `dbt-project/models/staging/sources.yml`.

## Esquema: `raw` (datos crudos de producción)

### `raw.pedidos`
- **Descripción:** Tabla de pedidos del sistema operacional. Se actualiza cada hora vía Airflow.
- **Clave primaria:** `id`
- **Columnas principales:** `id`, `cliente_id`, `estado`, `monto`, `fecha_creacion`, `fecha_actualizacion`
- **Notas:** Incluye pedidos en todos los estados, incluso borradores (`estado = 'draft'`). Filtrar en staging.

### `raw.clientes`
- **Descripción:** Registro de usuarios del sistema.
- **Clave primaria:** `id`
- **Columnas principales:** `id`, `email`, `nombre`, `fecha_registro`, `activo`
- **Notas:** Los clientes eliminados tienen `activo = false` pero no se borran de la tabla.

### `raw.productos`
- **Descripción:** Catálogo de productos.
- **Clave primaria:** `sku`
- **Columnas principales:** `sku`, `nombre`, `categoria`, `precio`, `activo`

## Frecuencia de actualización

| Tabla | Frecuencia | DAG de Airflow |
|-------|-----------|----------------|
| `raw.pedidos` | Cada hora | `pipeline_pedidos` |
| `raw.clientes` | Diaria a las 3am | `pipeline_clientes` |
| `raw.productos` | Diaria a las 2am | `pipeline_productos` |

## Cómo agregar una nueva fuente

1. Agregá la tabla acá con su descripción y columnas principales
2. Declarala en `dbt-project/models/staging/sources.yml`
3. Creá el modelo de staging correspondiente (`stg_[nombre].sql`)
4. Avisale al orquestador para que `@docs-agent` actualice la documentación
