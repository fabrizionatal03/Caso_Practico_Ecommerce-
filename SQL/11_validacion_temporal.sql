-- 11_validacion_temporal.sql
-- Diferencias temporales entre primera orden,
-- articulos e inventario.

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

detalle AS (
  SELECT
    pc.user_id,
    TIMESTAMP_DIFF(
      oi.created_at, pc.first_order_ts, SECOND
    ) AS desfase_item_seg,
    TIMESTAMP_DIFF(
      i.created_at, pc.first_order_ts, SECOND
    ) AS desfase_inventario_seg

  FROM primera_compra pc
  JOIN `bussiness-case-tyc.bussiness_case_ecommerce.order_items` oi
    ON pc.first_order_id = oi.order_id
  LEFT JOIN `bussiness-case-tyc.bussiness_case_ecommerce.inventory_items` i
    ON oi.inventory_item_id = i.id
)

SELECT
  COUNT(*) AS total_articulos,
  COUNTIF(desfase_item_seg > 0) AS items_posteriores,
  COUNTIF(desfase_item_seg > 3600) AS items_mas_1_hora,
  COUNTIF(desfase_item_seg > 86400) AS items_mas_1_dia,
  ROUND(
    MAX(desfase_item_seg) / 3600.0, 2
  ) AS max_desfase_item_horas,
  COUNTIF(desfase_inventario_seg > 0)
    AS inventario_posterior,
  COUNTIF(desfase_inventario_seg > 86400)
    AS inventario_mas_1_dia
FROM detalle;