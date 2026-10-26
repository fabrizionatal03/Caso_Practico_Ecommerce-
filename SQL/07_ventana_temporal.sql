-- 07_ventana_temporal.sql
-- Identificar el periodo disponible de órdenes.

SELECT
  MIN(created_at) AS primera_fecha_disponible,
  MAX(created_at) AS ultima_fecha_disponible,
  TIMESTAMP_SUB(
    MAX(created_at),
    INTERVAL 60 DAY
  ) AS ultima_primera_compra_evaluable
FROM `bussiness-case-tyc.bussiness_case_ecommerce.orders`;
