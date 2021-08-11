-- Посчитать количество конверсий в платежи на каждый день января.

SELECT  
  DATE(created_at) AS date,
  COUNT(DISTINCT CASE WHEN converted_at = created_at THEN user_id END) AS conversions
FROM (
        SELECT
            user_id,
            created_at,
            is_organic,
            MIN(CASE WHEN event_name = 'purchase' THEN created_at END) OVER (PARTITION BY user_id) AS converted_at
        FROM events
        WHERE DATE(created_at) BETWEEN '2000-01-01' AND '2000-01-31'
     ) AS a
GROUP BY created_date
