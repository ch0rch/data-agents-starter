-- models/staging/stg_clientes.sql
-- Limpieza 1:1 de la tabla raw.clientes
-- Normaliza nombres y emails, excluye registros duplicados

WITH source AS (
    SELECT * FROM {{ source('raw', 'clientes') }}
),

limpieza AS (
    SELECT
        id                              AS cliente_id,
        LOWER(TRIM(email))              AS email,
        TRIM(nombre)                    AS nombre,
        fecha_registro                  AS fecha_registro,
        -- Normalizar campo activo a booleano explícito
        COALESCE(activo, true)          AS es_activo_sistema
    FROM source
    -- Excluir registros sin email válido
    WHERE email IS NOT NULL
      AND TRIM(email) != ''
),

-- Eliminar duplicados por email, quedándonos con el registro más reciente
dedup AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY email 
            ORDER BY fecha_registro DESC, cliente_id DESC
        ) AS rn
    FROM limpieza
)

SELECT
    cliente_id,
    email,
    nombre,
    fecha_registro,
    es_activo_sistema
FROM dedup
WHERE rn = 1
