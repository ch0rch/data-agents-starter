-- models/marts/fct_pedidos.sql
-- Tabla de hechos de pedidos. Un registro por pedido confirmado.
-- Solo incluye pedidos en estado final (entregado o cancelado).

{{ config(
    materialized='incremental',
    unique_key='pedido_id'
) }}

WITH pedidos AS (
    SELECT * FROM {{ ref('stg_pedidos') }}
),

clientes AS (
    SELECT * FROM {{ ref('stg_clientes') }}
),

final AS (
    SELECT
        p.pedido_id,
        p.cliente_id,
        c.nombre                AS nombre_cliente,
        p.estado,
        p.monto_total,
        p.fecha_pedido,
        p.actualizado_at
    FROM pedidos AS p
    LEFT JOIN clientes AS c ON p.cliente_id = c.cliente_id
    -- Solo pedidos en estado final
    WHERE p.estado IN ('entregado', 'cancelado')
)

SELECT * FROM final

{% if is_incremental() %}
    -- En ejecuciones incrementales, solo procesar pedidos nuevos o actualizados
    WHERE fecha_pedido > (SELECT MAX(fecha_pedido) FROM {{ this }})
{% endif %}
