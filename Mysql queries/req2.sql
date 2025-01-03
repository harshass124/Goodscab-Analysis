SELECT 
            c.city_name,
            d.month_name,
            count(t.trip_id) as actual_trips,
            mtt.total_target_trips as target_trips,
            CASE WHEN count(t.trip_id) >mtt.total_target_trips THEN 'Above target'
                 ELSE 'Below target'
			END AS performance_status,
            concat(
            Round(
                   (count(t.trip_id)-mtt.total_target_trips)*100/count(t.trip_id)
                   ,2),
                   '%') AS '%_difference'
FROM 
    dim_city c
		JOIN
	fact_trips t  ON c.city_id=t.city_id
         JOIN
	dim_date d     ON d.date=t.date
         JOIN
    targets_db.monthly_target_trips mtt 
         ON c.city_id=mtt.city_id AND d.start_of_month=mtt.month
GROUP BY c.city_name, d.month_name,mtt.total_target_trips ,start_of_month
ORDER BY MONTH(d.start_of_month)
