WITH city_month_revenue AS (
    -- Calculate total revenue for each city and month
    SELECT
        c.city_name,
        d.start_of_month,
        monthname(d.start_of_month) AS month_name, -- Extract month name
        SUM(t.fare_amount) AS monthly_revenue,
        SUM(SUM(t.fare_amount)) OVER (PARTITION BY c.city_name) AS total_city_revenue
    FROM 
        dim_city c
    JOIN 
        fact_trips t USING(city_id)
    JOIN
        dim_date d ON t.date = d.date
    GROUP BY c.city_name, d.start_of_month
),
highest_revenue_month AS (
    -- Identify the highest revenue month for each city
    SELECT
        city_name,
        start_of_month,
        month_name,
        monthly_revenue,
        total_city_revenue,
        RANK() OVER (PARTITION BY city_name ORDER BY monthly_revenue DESC) AS revenue_rank
    FROM 
        city_month_revenue
)
SELECT
    city_name,
    month_name AS highest_revenue_month, -- Use month name instead of date
    monthly_revenue AS revenue,
  
    ROUND((monthly_revenue / total_city_revenue) * 100, 2) AS pct_contribution
FROM 
    highest_revenue_month
WHERE 
    revenue_rank = 1 -- Select only the highest revenue month for each city
ORDER BY 
    pct_contribution DESC;


