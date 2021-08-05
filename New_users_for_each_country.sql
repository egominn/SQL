SELECT a.first_country,
      COUNT(DISTINCT CASE WHEN installed_at = created_at THEN user_id END) AS new_users
FROM (
    SELECT user_id,
           created_at,
           installed_at,
           FIRST_VALUE(country) OVER (PARTITION BY user_id ORDER BY created_at) AS first_country
   FROM events
   WHERE DATE(installed_at) BETWEEN '2000-01-01' AND '2000-01-31'
     ) AS a
GROUP BY first_country
