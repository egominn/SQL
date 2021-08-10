-- Посчитать количество пользователей на каждый день января для каждой страны. Разделить по acquisition type.

SELECT  first_country,
        DATE(created_at) AS created_date,
        COUNT(DISTINCT CASE WHEN is_organic = 1 THEN user_id END) AS organic_dau,
        count(DISTINCT CASE WHEN is_organic = 0 THEN user_id END) AS non_organic_dau
FROM (
      SELECT user_id,
            created_at,
            is_organic,
            FIRST_VALUE(country) OVER (PARTITION BY user_id ORDER BY created_at) AS first_country
      FROM events
      WHERE DATE(created_at) BETWEEN '2000-01-01' AND '2000-01-31'
     ) AS a
GROUP BY first_country, created_date
