-- Посчитать количество конверсий в платежи для каждой страны на каждый день января.

SELECT 
    DATE(created_at) AS date,
    first_country,
    COUNT(DISTINCT CASE WHEN converted_at = created_at THEN user_id END) AS conversions
FROM (
        SELECT
            user_id,
            created_at,
            is_organic,
            FIRST_VALUE(country) OVER (PARTITION BY user_id ORDER BY created_at) AS first_country,
            MIN(CASE WHEN event_name = 'purchase' THEN created_at END) OVER (PARTITION BY user_id) AS converted_at
        FROM events
        WHERE DATE(created_at) BETWEEN '2000-01-01' AND '2000-01-31'
     ) AS a
GROUP BY 1, 2
ORDER BY 2, 1
