-- 08_primera_compra_target.sql
-- Primera compra válida y recompra dentro de 60 días.

WITH parametros AS (
  SELECT
    MAX(created_at) AS fecha_corte
  FROM `bussiness-case-tyc.bussiness_case_ecommerce.orders`
),

ordenes_validas AS (
  SELECT
    order_id,
    user_id,
    created_at,
    status
  FROM `bussiness-case-tyc.bussiness_case_ecommerce.orders`
  WHERE status IN ('Complete', 'Shipped', 'Processing')
    AND order_id IS NOT NULL
    AND user_id IS NOT NULL
    AND created_at IS NOT NULL
),

ordenes_numeradas AS (
  SELECT
    *,
    ROW_NUMBER() OVER (
      PARTITION BY user_id
      ORDER BY created_at, order_id
    ) AS numero_compra
  FROM ordenes_validas
),

primera_compra AS (
  SELECT
    user_id,
    order_id AS first_order_id,
    created_at AS first_order_ts
  FROM ordenes_numeradas
  WHERE numero_compra = 1
),

recompras AS (
  SELECT
    p.user_id,
    COUNT(o.order_id) AS ordenes_posteriores_60d
  FROM primera_compra p
  LEFT JOIN ordenes_numeradas o
    ON p.user_id = o.user_id
    AND o.numero_compra > 1
    AND o.created_at <= TIMESTAMP_ADD(
      p.first_order_ts, INTERVAL 60 DAY
    )
  GROUP BY p.user_id
),

etiquetas AS (
  SELECT
    p.user_id,
    p.first_order_id,
    p.first_order_ts,
    par.fecha_corte,
    r.ordenes_posteriores_60d,
    CASE
      WHEN TIMESTAMP_ADD(
        p.first_order_ts, INTERVAL 60 DAY
      ) > par.fecha_corte THEN NULL
      WHEN r.ordenes_posteriores_60d > 0 THEN 1
      ELSE 0
    END AS repurchase_60d
  FROM primera_compra p
  JOIN recompras r USING (user_id)
  CROSS JOIN parametros par
)

SELECT
  COUNT(*) AS clientes_con_primera_compra,
  COUNTIF(repurchase_60d = 1) AS recompra_si,
  COUNTIF(repurchase_60d = 0) AS recompra_no,
  COUNTIF(repurchase_60d IS NULL) AS sin_60_dias_completos,
  ROUND(
    100 * SAFE_DIVIDE(
      COUNTIF(repurchase_60d = 1),
      COUNTIF(repurchase_60d IS NOT NULL)
    ), 2
  ) AS tasa_recompra_pct
FROM etiquetas;