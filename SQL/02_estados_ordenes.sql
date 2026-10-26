-- 02_estados_ordenes.sql

SELECT
  status,
  COUNT(*) AS total_ordenes,
  COUNT(DISTINCT user_id) AS clientes,
  MIN(created_at) AS primera_fecha,
  MAX(created_at) AS ultima_fecha,
  COUNTIF(order_id IS NULL) AS order_id_nulos,
  COUNTIF(user_id IS NULL) AS user_id_nulos,
  COUNTIF(created_at IS NULL) AS fechas_nulas
FROM `bussiness-case-tyc.bussiness_case_ecommerce.orders`
GROUP BY status
ORDER BY total_ordenes DESC;
