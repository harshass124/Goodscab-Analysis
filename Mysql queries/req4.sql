WITH ranked_cities AS (
    SELECT
        c.city_name,
        SUM(p.new_passengers) AS Total_new_passengers,
        RANK() OVER (ORDER BY SUM(p.new_passengers) DESC) AS rank_desc,
        RANK() OVER (ORDER BY SUM(p.new_passengers)) AS rank_asc
    FROM 
        dim_city c
    JOIN
        fact_passenger_summary p  
        ON c.city_id = p.city_id
    GROUP BY c.city_name
)
SELECT
    city_name,
    Total_new_passengers,
    CASE
        WHEN rank_desc <= 3 THEN 'Top3'
        WHEN rank_asc <= 3 THEN 'Bottom3'
    END AS city_category
FROM ranked_cities
WHERE
    (rank_desc <= 3 OR rank_asc <= 3)  -- Only include rows where city_category is 'Top3' or 'Bottom3'
ORDER BY Total_new_passengers DESC;
