SELECT DATE(installed_at), COUNT(DISTINCT user_id)
FROM events
GROUP BY DATE(installed_at)
