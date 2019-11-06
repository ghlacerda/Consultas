WITH Hours AS
(
  SELECT 0 as hour
  UNION ALL
  SELECT  hour + 1
  FROM    Hours   
  WHERE   hour + 1 < 24
)
SELECT 
		CASE
			WHEN [hour] = 0 THEN  '00:00:00.000'
			WHEN [hour] = 1 THEN  '01:00:00.000'
			WHEN [hour] = 2 THEN  '02:00:00.000'
			WHEN [hour] = 3 THEN  '03:00:00.000'
			WHEN [hour] = 4 THEN  '04:00:00.000'
			WHEN [hour] = 5 THEN  '05:00:00.000'
			WHEN [hour] = 6 THEN  '06:00:00.000'
			WHEN [hour] = 7 THEN  '07:00:00.000'
			WHEN [hour] = 8 THEN  '08:00:00.000'
			WHEN [hour] = 9 THEN  '09:00:00.000'
			WHEN [hour] = 10 THEN  '10:00:00.000'
			WHEN [hour] = 11 THEN  '11:00:00.000'
			WHEN [hour] = 12 THEN  '12:00:00.000'
			WHEN [hour] = 13 THEN  '13:00:00.000'
			WHEN [hour] = 14 THEN  '14:00:00.000'
			WHEN [hour] = 15 THEN  '15:00:00.000'
			WHEN [hour] = 16 THEN  '16:00:00.000'
			WHEN [hour] = 17 THEN  '17:00:00.000'
			WHEN [hour] = 18 THEN  '18:00:00.000'
			WHEN [hour] = 19 THEN  '19:00:00.000'
			WHEN [hour] = 20 THEN  '20:00:00.000'
			WHEN [hour] = 21 THEN  '21:00:00.000'
			WHEN [hour] = 22 THEN  '22:00:00.000'
			WHEN [hour] = 23 THEN  '23:00:00.000'		
		ELSE ''
		END AS HORAS	
FROM    Hours h
