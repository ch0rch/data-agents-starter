-- models/staging/stg_pedidos.sql
-- Limpieza 1:1 de la tabla raw.pedidos
-- Excluye pedidos en estado 'draft' que no son pedidos reales

WITH source AS (
    SELECT * FROM {{ source('raw', 'pedidos') }}
),

limpieza AS (
    SELECT
        id                          AS pedido_id,
        cliente_id,
        LOWER(TRIM(estado))         AS estado,
        monto                       AS monto_total,
        fecha_creacion              AS fecha_pedido,
        fecha_actualizacion         AS actualizado_at
    FROM source
    -- Excluir borradores y registros sin cliente asignado
    WHERE estado != 'draft'
      AND cliente_id IS NOT NULL
)

SELECT * FROM limpieza
