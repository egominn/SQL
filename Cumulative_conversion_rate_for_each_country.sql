-- Посчитать Cumulative Conversion Rate для каждой страны отдельно по всем известным дням после установки.

SELECT
    c.*,
    CAST(total_conversions AS double precision) / CAST(cohort_size AS double precision) AS cum_conversion_rate
FROM (
       SELECT
            b.*,
            MAX(b.retained_users) OVER (PARTITION BY b.first_country) AS cohort_size,
            SUM(b.conversions) OVER (PARTITION BY b.first_country ORDER BY b.day_after_install) AS total_conversions
       FROM (
              SELECT
                    a.first_country,
                    DATE_PART('day', a.created_at - a.installed_at) AS day_after_install,
                    COUNT(DISTINCT a.user_id) AS retained_users,
                    COUNT(DISTINCT CASE WHEN converted_at = created_at THEN user_id END) AS conversions
               FROM (
                      SELECT
                           user_id,
                           installed_at,
                           created_at,
                           event_name,
                           FIRST_VALUE(country) OVER (PARTITION BY user_id ORDER BY created_at) AS first_country,
                           MIN(CASE WHEN event_name = 'purchase' THEN created_at end) OVER (PARTITION BY user_id) AS converted_at
                       FROM events
                       WHERE installed_at >= '2000-01-01'
                             AND installed_at < '2000-02-01'
                     ) AS a
               GROUP BY first_country, day_after_install
             ) AS b
     ) AS c
