-- 09_features_primera_compra.sql
-- Construccion de variables de la primera orden.
-- Resultado: resumen de validacion.

WITH ordenes_validas AS (
  SELECT
    order_id,
    user_id,
    created_at
  FROM `bussiness-case-tyc.bussiness_case_ecommerce.orders`
  WHERE status IN ('Complete', 'Shipped', 'Processing')
    AND order_id IS NOT NULL
    AND user_id IS NOT NULL
    AND created_at IS NOT NULL
),

primera_compra AS (
  SELECT
    user_id,
    order_id AS first_order_id,
    created_at AS first_order_ts
  FROM ordenes_validas
  QUALIFY ROW_NUMBER() OVER (
    PARTITION BY user_id
    ORDER BY created_at, order_id
  ) = 1
),

variables_primera_compra AS (
  SELECT
    pc.user_id,
    pc.first_order_id,
    pc.first_order_ts,

    COUNT(oi.id) AS n_items,
    ROUND(SUM(oi.sale_price), 2) AS order_value,
    COUNT(DISTINCT oi.product_id) AS n_distinct_products,
    COUNT(DISTINCT p.category) AS n_categories,
    COUNT(DISTINCT p.brand) AS n_brands,

    ROUND(SUM(i.cost), 2) AS order_cost,
    ROUND(SUM(oi.sale_price - i.cost), 2) AS order_margin,

    COUNTIF(oi.created_at > pc.first_order_ts)
      AS items_registrados_despues,

    COUNTIF(i.created_at > pc.first_order_ts)
      AS inventario_registrado_despues,

    COUNTIF(i.cost IS NULL)
      AS costos_nulos

  FROM primera_compra pc

  JOIN `bussiness-case-tyc.bussiness_case_ecommerce.order_items` oi
    ON pc.first_order_id = oi.order_id

  LEFT JOIN `bussiness-case-tyc.bussiness_case_ecommerce.products` p
    ON oi.product_id = p.id

  LEFT JOIN `bussiness-case-tyc.bussiness_case_ecommerce.inventory_items` i
    ON oi.inventory_item_id = i.id

  GROUP BY 1, 2, 3
)

SELECT
  COUNT(*) AS clientes_con_variables,
  COUNT(DISTINCT user_id) AS clientes_unicos,
  COUNTIF(n_items = 0) AS compras_sin_items,
  COUNTIF(costos_nulos > 0) AS compras_con_costos_nulos,
  SUM(items_registrados_despues) AS items_registrados_despues,
  SUM(inventario_registrado_despues) AS inventario_registrado_despues,
  ROUND(AVG(n_items), 2) AS promedio_items,
  ROUND(AVG(order_value), 2) AS ticket_promedio,
  ROUND(AVG(order_margin), 2) AS margen_promedio
FROM variables_primera_compra;