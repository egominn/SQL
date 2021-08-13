-- Посчитать Retention Rate для каждой страны отдельно по всем известным дням после установки.

SELECT
    b.first_country,
    b.day_after_install,
    b.retained_users * 1.0 / (FIRST_VALUE(b.retained_users) OVER (PARTITION BY b.first_country ORDER BY b.day_after_install)) * 1.0 AS retention_rate
FROM (
       SELECT
            a.first_country,
            date_part('day', a.created_at - a.installed_at) AS day_after_install,
            COUNT(DISTINCT a.user_id) AS retained_users
       FROM (
               SELECT
                    user_id,
                    installed_at,
                    created_at,
                    event_name,
                    FIRST_VALUE(country) OVER (PARTITION BY user_id ORDER BY created_at) AS first_country
               FROM events
            ) AS a
       GROUP BY a.first_country, date_part('day', a.created_at - a.installed_at)
    ) AS b
