-- Посчитать количество новых пользователей для каждой страны на каждый день января. Разделить по acquisition type.

SELECT  first_country,
        DATE(installed_at) AS installed_date,
        COUNT(DISTINCT CASE WHEN installed_at = created_at AND is_organic = 1 THEN user_id END) AS new_organic_users,
        COUNT(DISTINCT CASE WHEN installed_at = created_at AND is_organic = 0 THEN user_id END) AS new_non_organic_users
FROM (
    SELECT user_id,
           created_at,
           installed_at,
           is_organic,
           FIRST_VALUE(country) OVER (PARTITION BY user_id ORDER BY created_at) AS first_country
   FROM events
   WHERE DATE(installed_at) BETWEEN '2000-01-01' AND '2000-01-31'
        ) AS a
GROUP BY first_country, installed_date
