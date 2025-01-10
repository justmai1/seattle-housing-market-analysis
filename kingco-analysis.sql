-- Average Housing Prices by City

SELECT DATEPART(year, sale_date) as year, city, ROUND(AVG(sale_price),2) as avg_sale_price
FROM kingco_sales
WHERE DATEPART(year, sale_date) >= 2000
AND (city = 'SEATTLE' OR city = 'BELLEVUE' OR city = 'KING COUNTY')
GROUP BY DATEPART(year, sale_date), city
ORDER BY city, year;

-- Yearly Home Appreciation Percentage(by city)

WITH average_sale_price as(
    SELECT DATEPART(year, sale_date) as year, city, ROUND(AVG(sale_price),2) as avg_sale_price
    FROM kingco_sales
    WHERE DATEPART(year, sale_date) >= 1999
    GROUP BY DATEPART(year, sale_date), city
), home_appreciation as(
SELECT year, city, avg_sale_price/(LAG(avg_sale_price) OVER (PARTITION BY city ORDER BY year)) as home_appreciation
FROM average_sale_price
)
SELECT * FROM home_appreciation
WHERE year > 1999;

-- Yearly Home Appreciation Value (by city)
WITH average_sale_price as(
    SELECT DATEPART(year, sale_date) as year, city, ROUND(AVG(sale_price),2) as avg_sale_price
    FROM kingco_sales
    WHERE DATEPART(year, sale_date) >= 1999
    GROUP BY DATEPART(year, sale_date), city
), home_appreciation as(
SELECT year, city, avg_sale_price - (LAG(avg_sale_price) OVER (PARTITION BY city ORDER BY year)) as home_appreciation
FROM average_sale_price
)
SELECT * FROM home_appreciation
WHERE year > 1999;

-- Price per sq. ft.

WITH ppsqft as(
    SELECT DATEPART(year, sale_date) as year, city, sale_price/sqft as ppsqft
    FROM kingco_sales
    WHERE DATEPART(year, sale_date) >= 2000
)
SELECT year, city, AVG(ppsqft) as price_per_sqft
FROM ppsqft
GROUP BY city, year
ORDER BY city, year
