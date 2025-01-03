WITH total_trips_cte AS (
    SELECT 
        SUM(COUNT(t.trip_id)) OVER() AS total_trips
    FROM 
        fact_trips t
    GROUP BY 
        t.city_id
),
total_trips_agg AS (
    SELECT DISTINCT total_trips FROM total_trips_cte
)
SELECT 
    c.city_name,
    COUNT(t.trip_id) AS total_trips,
    ROUND(AVG(t.fare_amount / NULLIF(t.distance_travelled_km, 0)), 2) AS avg_fare_per_km,
    ROUND(AVG(t.fare_amount), 2) AS avg_fare_per_trip,
    CONCAT(
        ROUND(
            COUNT(t.trip_id) * 100.0 / (SELECT total_trips FROM total_trips_agg),
            2
        ),
        '%'
    ) AS pct_contribution_to_total_trips
FROM 
    dim_city c
    LEFT JOIN fact_trips t ON c.city_id = t.city_id
GROUP BY 
    c.city_name
ORDER BY 
    pct_contribution_to_total_trips DESC;
