WITH monthly_repeat_rate AS (
    -- Calculate the monthly repeat passenger rate for each city and month
    SELECT
        c.city_name,
        d.start_of_month,
        SUM(f.repeat_passengers) AS total_repeat_passengers_month,
        SUM(f.total_passengers) AS total_passengers_month,
        ROUND((SUM(f.repeat_passengers) * 100.0) / NULLIF(SUM(f.total_passengers), 0), 2) AS monthly_repeat_passenger_rate
    FROM 
        dim_city c
    JOIN 
        fact_passenger_summary f USING(city_id)
    JOIN
        dim_date d ON f.month = d.start_of_month
    GROUP BY c.city_name, d.start_of_month
),
citywide_repeat_rate AS (
    -- Calculate the citywide repeat passenger rate for each city
    SELECT
        c.city_name,
        SUM(f.repeat_passengers) AS total_repeat_passengers_city,
        SUM(f.total_passengers) AS total_passengers_city,
        ROUND((SUM(f.repeat_passengers) * 100.0) / NULLIF(SUM(f.total_passengers), 0), 2) AS citywide_repeat_passenger_rate
    FROM 
        dim_city c
    JOIN 
        fact_passenger_summary f USING(city_id)
    GROUP BY c.city_name
)
SELECT
    m.city_name,
   monthname( m.start_of_month) AS month,
   total_passengers_month AS Total_Passengers,
   total_repeat_passengers_month AS Repeat_Passengers,
    m.monthly_repeat_passenger_rate,
    c.citywide_repeat_passenger_rate
FROM 
    monthly_repeat_rate m
JOIN 
    citywide_repeat_rate c ON m.city_name = c.city_name
ORDER BY 
    m.city_name, m.start_of_month;
