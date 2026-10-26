-- 10_eventos_previos.sql
-- Evaluar la disponibilidad de actividad web anterior
-- a la primera compra de cada cliente.

WITH primera_compra AS (
  SELECT
    user_id,
    order_id AS first_order_id,
    created_at AS first_order_ts
  FROM `bussiness-case-tyc.bussiness_case_ecommerce.orders`
  WHERE status IN ('Complete', 'Shipped', 'Processing')
    AND user_id IS NOT NULL
    AND created_at IS NOT NULL
  QUALIFY ROW_NUMBER() OVER (
    PARTITION BY user_id
    ORDER BY created_at, order_id
  ) = 1
),

actividad_previa AS (
  SELECT
    pc.user_id,

    COUNT(e.id) AS n_events_pre,
    COUNT(DISTINCT e.session_id) AS n_sessions_pre,
    COUNTIF(e.event_type = 'product') AS n_product_views_pre,
    COUNTIF(e.event_type = 'cart') AS n_cart_events_pre

  FROM primera_compra pc

LEFT JOIN `bussiness-case-tyc.bussiness_case_ecommerce.events` e
  ON pc.user_id = e.user_id
  AND e.created_at < pc.first_order_ts
  AND e.event_type IN (
    'product', 'cart', 'department', 'home'
  )

  GROUP BY pc.user_id
)

SELECT
  COUNT(*) AS clientes,
  COUNTIF(n_events_pre = 0) AS clientes_sin_eventos_previos,
  COUNTIF(n_events_pre > 0) AS clientes_con_eventos_previos,
  ROUND(AVG(n_events_pre), 2) AS promedio_eventos_previos,
  ROUND(AVG(n_sessions_pre), 2) AS promedio_sesiones_previas,
  ROUND(AVG(n_product_views_pre), 2) AS promedio_visitas_productos,
  ROUND(AVG(n_cart_events_pre), 2) AS promedio_eventos_carrito
FROM actividad_previa;