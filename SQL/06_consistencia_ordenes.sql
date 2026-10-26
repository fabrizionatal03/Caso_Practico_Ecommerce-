-- 06_consistencia_ordenes.sql
-- Validar cantidad de artículos, estados y clientes.

WITH resumen_items AS (
  SELECT
    order_id,
    COUNT(*) AS cantidad_items
  FROM `bussiness-case-tyc.bussiness_case_ecommerce.order_items`
  GROUP BY order_id
),

validacion AS (
  SELECT
    o.order_id,
    o.num_of_item,
    COALESCE(ri.cantidad_items, 0) AS cantidad_real
  FROM `bussiness-case-tyc.bussiness_case_ecommerce.orders` o
  LEFT JOIN resumen_items ri
    ON o.order_id = ri.order_id
)

SELECT
  'cantidad_items_incorrecta' AS control,
  COUNTIF(num_of_item IS DISTINCT FROM cantidad_real) AS incidencias
FROM validacion

UNION ALL

SELECT
  'estado_inconsistente',
  COUNTIF(o.status IS DISTINCT FROM oi.status)
FROM `bussiness-case-tyc.bussiness_case_ecommerce.order_items` oi
JOIN `bussiness-case-tyc.bussiness_case_ecommerce.orders` o
  ON oi.order_id = o.order_id

UNION ALL

SELECT
  'cliente_inconsistente',
  COUNTIF(o.user_id IS DISTINCT FROM oi.user_id)
FROM `bussiness-case-tyc.bussiness_case_ecommerce.order_items` oi
JOIN `bussiness-case-tyc.bussiness_case_ecommerce.orders` o
  ON oi.order_id = o.order_id;