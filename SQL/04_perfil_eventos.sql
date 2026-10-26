-- 04_perfil_eventos.sql

SELECT
  event_type,
  COUNT(*) AS total_eventos,
  COUNT(DISTINCT user_id) AS usuarios_distintos,
  COUNTIF(user_id IS NULL) AS usuarios_nulos,
  COUNTIF(created_at IS NULL) AS fechas_nulas,
  MIN(created_at) AS primera_fecha,
  MAX(created_at) AS ultima_fecha
FROM `bussiness-case-tyc.bussiness_case_ecommerce.events`
GROUP BY event_type
ORDER BY total_eventos DESC;