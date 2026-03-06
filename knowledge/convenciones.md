# Convenciones del Proyecto

## Nomenclatura de modelos

| Capa | Prefijo | Ejemplo | Qué contiene |
|------|---------|---------|--------------|
| Staging | `stg_` | `stg_pedidos.sql` | Limpieza 1:1 de una tabla fuente |
| Intermediate | `int_` | `int_pedidos_con_cliente.sql` | Joins y lógica de negocio |
| Facts | `fct_` | `fct_pedidos.sql` | Métricas y hechos del negocio |
| Dimensions | `dim_` | `dim_clientes.sql` | Entidades descriptivas |
| Seeds | `seed_` | `seed_estados.csv` | Datos estáticos de referencia |

## Estilo SQL

- Palabras clave en MAYÚSCULAS: `SELECT`, `FROM`, `WHERE`, `JOIN`, `GROUP BY`
- Nombres de columnas y tablas en snake_case minúscula
- Siempre usar alias en los JOINs: `FROM pedidos AS p`
- Una columna por línea en el SELECT
- Agregar comentario encima de la lógica no obvia

```sql
-- Bien
SELECT
    p.pedido_id,
    p.fecha_pedido,
    c.nombre AS nombre_cliente,
    -- Solo pedidos con monto mayor a cero para excluir cortesías
    p.monto_total
FROM {{ ref('stg_pedidos') }} AS p
LEFT JOIN {{ ref('stg_clientes') }} AS c ON p.cliente_id = c.cliente_id
WHERE p.monto_total > 0

-- Mal
select p.pedido_id, p.fecha_pedido, c.nombre as nombre_cliente, p.monto_total from stg_pedidos p left join stg_clientes c on p.cliente_id = c.cliente_id where p.monto_total > 0
```

## Nombres de columnas

- Claves primarias: `[entidad]_id` → `pedido_id`, `cliente_id`
- Fechas: `fecha_[evento]` → `fecha_pedido`, `fecha_entrega`
- Timestamps: `[evento]_at` → `creado_at`, `actualizado_at`
- Booleanos: `es_[condicion]` o `tiene_[condicion]` → `es_activo`, `tiene_descuento`
- Montos: `monto_[concepto]` → `monto_total`, `monto_descuento`

## Materialización por defecto

```yaml
# dbt_project.yml
models:
  mi_proyecto:
    staging:
      +materialized: view      # Staging siempre como vista
    intermediate:
      +materialized: view      # Intermediate también
    marts:
      +materialized: table     # Marts como tabla física
```

## Tests obligatorios

Todo modelo nuevo en `marts/` debe tener al menos:
- `unique` + `not_null` en la clave primaria
- `relationships` en todas las FKs
- `accepted_values` en columnas de estado o tipo

## Descripciones en schema.yml

- Primera oración: qué contiene el modelo / la columna (el "qué")
- Segunda oración opcional: qué excluye o casos especiales (el "qué no")
- Evitar descripciones vacías o tautológicas: "Columna id" no es una descripción útil
