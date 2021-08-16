-- Посчитать CARPU для каждого дня января и страны отдельно по всем известным дням после установки.

SELECT
      c.*,
      CAST(total_conversions AS double precision) / CAST(cohort_size AS double precision) AS cum_conversion_rate,
      total_purchases_revenue / CAST(cohort_size AS double precision) AS CARPU
FROM (
       SELECT
             b.*,
             MAX(b.retained_users) OVER (PARTITION BY b.first_country, b.installed_date) AS cohort_size,
             SUM(b.conversions) OVER (PARTITION BY b.first_country, b.installed_date ORDER BY b.day_after_install) AS total_conversions,
             SUM(b.purchases_revenue) OVER (PARTITION BY b.first_country, b.installed_date ORDER BY b.day_after_install) AS total_purchases_revenue
       FROM (
              SELECT
                    a.first_country,
                    DATE(a.installed_at) AS installed_date,
                    DATE_PART('day', a.created_at - a.installed_at) AS day_after_install,
                    COUNT(DISTINCT a.user_id) AS retained_users,
                    COUNT(DISTINCT CASE WHEN a.converted_at = a.created_at THEN a.user_id END) AS conversions,
                    SUM(a.purchases_revenue) AS purchases_revenue
               FROM (
                      SELECT
                            user_id,
                            installed_at,
                            created_at,
                            event_name,
                            FIRST_VALUE(country) OVER (PARTITION BY user_id ORDER BY created_at) AS first_country,
                            MIN(CASE WHEN event_name = 'purchase' THEN created_at END) OVER (PARTITION BY user_id) AS converted_at,
                            SUM(CASE WHEN event_name = 'purchase' THEN revenue END) OVER (PARTITION BY user_id) AS purchases_revenue
                       FROM events
                       WHERE installed_at >= '2000-01-01'
                             AND installed_at < '2000-02-01'
                    ) AS a
               GROUP BY first_country, installed_date, day_after_install
            ) AS b
     ) AS c
