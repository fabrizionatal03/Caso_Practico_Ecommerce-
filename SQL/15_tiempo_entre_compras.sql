-- Tiempo entre la primera y segunda orden válida.
-- Solo clientes con 60 días completos de observación.

WITH fecha_corte AS (
  SELECT MAX(created_at) AS cutoff
  FROM `bussiness-case-tyc.bussiness_case_ecommerce.orders`
),

ordenes_validas AS (
  SELECT
    user_id,
    order_id,
    created_at,
    ROW_NUMBER() OVER (
      PARTITION BY user_id
      ORDER BY created_at, order_id
    ) AS numero_orden
  FROM `bussiness-case-tyc.bussiness_case_ecommerce.orders`
  WHERE status IN ('Complete', 'Shipped', 'Processing')
    AND user_id IS NOT NULL
    AND order_id IS NOT NULL
    AND created_at IS NOT NULL
),

compras AS (
  SELECT
    user_id,
    MAX(IF(numero_orden = 1, created_at, NULL))
      AS primera_compra,
    MAX(IF(numero_orden = 2, created_at, NULL))
      AS segunda_compra
  FROM ordenes_validas
  WHERE numero_orden <= 2
  GROUP BY user_id
)

SELECT
  c.user_id,
  c.primera_compra,
  c.segunda_compra,
  ROUND(
    TIMESTAMP_DIFF(
      c.segunda_compra,
      c.primera_compra,
      SECOND
    ) / 86400.0, 2
  ) AS dias_hasta_recompra
FROM compras c
CROSS JOIN fecha_corte f
WHERE c.primera_compra <= TIMESTAMP_SUB(
    f.cutoff, INTERVAL 60 DAY
  )
  AND c.segunda_compra IS NOT NULL
  AND c.segunda_compra <= TIMESTAMP_ADD(
    c.primera_compra, INTERVAL 60 DAY
  )
ORDER BY dias_hasta_recompra;