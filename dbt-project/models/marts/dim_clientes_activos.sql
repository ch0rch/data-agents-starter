-- models/marts/dim_clientes_activos.sql
-- Dimensión de clientes activos con métricas de negocio
-- 
-- DEFINICIÓN DE "CLIENTE ACTIVO":
-- Un cliente se considera activo cuando cumple TODAS estas condiciones:
--   1. Está marcado como activo en el sistema (es_activo_sistema = true)
--   2. Ha realizado al menos un pedido entregado
--   3. Su última compra fue hace menos de 12 meses (365 días)
--   4. No es un cliente que solo cancela (tasa de cancelación < 80%)
--
-- Esto excluye a:
--   - Clientes dados de baja en el sistema
--   - Registros que nunca convirtieron
--   - Clientes churned (sin actividad reciente)
--   - Cuentas problemáticas (solo cancelaciones)

{{ config(
    materialized='table',
    unique_key='cliente_id'
) }}

WITH metricas AS (
    SELECT * FROM {{ ref('int_clientes_con_metricas') }}
),

clasificacion AS (
    SELECT
        cliente_id,
        email,
        nombre,
        fecha_registro,
        es_activo_sistema,
        total_pedidos,
        pedidos_entregados,
        pedidos_cancelados,
        monto_total_comprado,
        ticket_promedio,
        fecha_primer_pedido,
        fecha_ultimo_pedido,
        dias_desde_ultimo_pedido,
        segmento_recencia,
        
        -- Cálculo de tasa de cancelación
        CASE 
            WHEN total_pedidos > 0 
            THEN ROUND(pedidos_cancelados::NUMERIC / total_pedidos, 2)
            ELSE 0 
        END AS tasa_cancelacion,
        
        -- Antigüedad en días desde el registro
        EXTRACT(DAY FROM CURRENT_TIMESTAMP - fecha_registro) AS dias_desde_registro,
        
        -- Frecuencia de compra (pedidos por mes desde el primer pedido)
        CASE 
            WHEN fecha_primer_pedido IS NOT NULL 
            THEN ROUND(
                total_pedidos::NUMERIC / 
                NULLIF(EXTRACT(DAY FROM CURRENT_TIMESTAMP - fecha_primer_pedido) / 30.0, 0),
                2
            )
            ELSE 0 
        END AS frecuencia_mensual
        
    FROM metricas
),

clientes_activos AS (
    SELECT
        *,
        -- Definición final de cliente activo
        CASE 
            WHEN es_activo_sistema = false THEN false
            WHEN pedidos_entregados = 0 THEN false
            WHEN dias_desde_ultimo_pedido > 365 THEN false
            WHEN tasa_cancelacion >= 0.80 THEN false
            ELSE true
        END AS es_cliente_activo,
        
        -- Clasificación más detallada
        CASE 
            WHEN es_activo_sistema = false THEN 'inactivo_sistema'
            WHEN pedidos_entregados = 0 THEN 'sin_compras'
            WHEN dias_desde_ultimo_pedido > 365 THEN 'churned'
            WHEN tasa_cancelacion >= 0.80 THEN 'solo_cancelaciones'
            WHEN dias_desde_ultimo_pedido <= 30 THEN 'activo_reciente'
            WHEN dias_desde_ultimo_pedido <= 90 THEN 'activo_regular'
            ELSE 'activo_ocasional'
        END AS estado_cliente
        
    FROM clasificacion
)

SELECT
    cliente_id,
    email,
    nombre,
    fecha_registro,
    es_activo_sistema,
    es_cliente_activo,
    estado_cliente,
    total_pedidos,
    pedidos_entregados,
    pedidos_cancelados,
    tasa_cancelacion,
    monto_total_comprado,
    ticket_promedio,
    fecha_primer_pedido,
    fecha_ultimo_pedido,
    dias_desde_ultimo_pedido,
    dias_desde_registro,
    frecuencia_mensual,
    segmento_recencia
FROM clientes_activos
WHERE es_cliente_activo = true
