-- models/intermediate/int_clientes_con_metricas.sql
-- Calcula métricas de actividad por cliente basadas en pedidos
-- Incluye totales, fechas de última actividad y segmentación básica

WITH clientes AS (
    SELECT 
        cliente_id,
        email,
        nombre,
        fecha_registro,
        es_activo_sistema
    FROM {{ ref('stg_clientes') }}
),

pedidos AS (
    SELECT 
        pedido_id,
        cliente_id,
        estado,
        monto_total,
        fecha_pedido
    FROM {{ ref('stg_pedidos') }}
),

metricas_pedidos AS (
    SELECT
        cliente_id,
        COUNT(*) AS total_pedidos,
        COUNT(DISTINCT DATE_TRUNC('month', fecha_pedido)) AS meses_con_pedidos,
        SUM(CASE WHEN estado = 'entregado' THEN 1 ELSE 0 END) AS pedidos_entregados,
        SUM(CASE WHEN estado = 'cancelado' THEN 1 ELSE 0 END) AS pedidos_cancelados,
        SUM(CASE WHEN estado = 'entregado' THEN monto_total ELSE 0 END) AS monto_total_comprado,
        AVG(CASE WHEN estado = 'entregado' THEN monto_total END) AS ticket_promedio,
        MIN(fecha_pedido) AS fecha_primer_pedido,
        MAX(fecha_pedido) AS fecha_ultimo_pedido,
        -- Días desde la última compra (hasta hoy)
        EXTRACT(DAY FROM CURRENT_TIMESTAMP - MAX(fecha_pedido)) AS dias_desde_ultimo_pedido
    FROM pedidos
    GROUP BY cliente_id
),

final AS (
    SELECT
        c.cliente_id,
        c.email,
        c.nombre,
        c.fecha_registro,
        c.es_activo_sistema,
        
        -- Métricas de pedidos (NULL si nunca compró)
        COALESCE(m.total_pedidos, 0) AS total_pedidos,
        COALESCE(m.meses_con_pedidos, 0) AS meses_con_pedidos,
        COALESCE(m.pedidos_entregados, 0) AS pedidos_entregados,
        COALESCE(m.pedidos_cancelados, 0) AS pedidos_cancelados,
        COALESCE(m.monto_total_comprado, 0) AS monto_total_comprado,
        m.ticket_promedio,
        m.fecha_primer_pedido,
        m.fecha_ultimo_pedido,
        m.dias_desde_ultimo_pedido,
        
        -- Flags de comportamiento
        CASE 
            WHEN m.total_pedidos IS NULL THEN 'nunca_compro'
            WHEN m.pedidos_entregados = 0 THEN 'solo_cancelados'
            WHEN m.dias_desde_ultimo_pedido <= 30 THEN 'compra_reciente'
            WHEN m.dias_desde_ultimo_pedido <= 90 THEN 'compra_moderada'
            ELSE 'compra_antigua'
        END AS segmento_recencia
        
    FROM clientes AS c
    LEFT JOIN metricas_pedidos AS m ON c.cliente_id = m.cliente_id
)

SELECT * FROM final
