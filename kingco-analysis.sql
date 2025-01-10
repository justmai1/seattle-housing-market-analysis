-- Average Housing Prices by City

SELECT DATEPART(year, sale_date) as year, city, ROUND(AVG(sale_price),2) as avg_sale_price
FROM kingco_sales
WHERE DATEPART(year, sale_date) >= 2000
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
ORDER BY city, year;

-- Average annual income growth rate (percentage) vs Average rate of growth for home prices (percentage)
WITH initial as(
    SELECT DATEPART(year,observation_date) as year, annual_income as income
    FROM seattle_aai
    WHERE DATEPART(year,observation_date) >= 1999
), rates as(
    SELECT year + 1 as year, (((LEAD(income) OVER (ORDER BY year)) / income) - 1)*100 as rate
    FROM initial
)
SELECT ROUND(AVG(rate),2) as avg_rate
FROM rates;

WITH initial as(
    SELECT DATEPART(year,observation_date) as year, annual_income as income
    FROM seattle_aai
    WHERE DATEPART(year,observation_date) >= 2010
), rates as(
    SELECT year + 1 as year, (((LEAD(income) OVER (ORDER BY year)) / income) - 1)*100 as rate
    FROM initial
)
SELECT ROUND(AVG(rate),2) as avg_rate
FROM rates;

WITH average_sale_price as(
    SELECT DATEPART(year, sale_date) as year, city, ROUND(AVG(sale_price),2) as avg_sale_price
    FROM kingco_sales
    WHERE DATEPART(year, sale_date) >= 1999
    GROUP BY DATEPART(year, sale_date), city
), rate as(
    SELECT year + 1 as year, 
        city, 
        (((LEAD(avg_sale_price) OVER (PARTITION BY city ORDER BY year) / avg_sale_price) - 1) * 100) as rate
    FROM average_sale_price
)
SELECT city, ROUND(AVG(rate),2) avg_rate
FROM rate
GROUP BY city;

WITH average_sale_price as(
    SELECT DATEPART(year, sale_date) as year, city, ROUND(AVG(sale_price),2) as avg_sale_price
    FROM kingco_sales
    WHERE DATEPART(year, sale_date) >= 2010
    GROUP BY DATEPART(year, sale_date), city
), rate as(
    SELECT year + 1 as year, 
        city, 
        (((LEAD(avg_sale_price) OVER (PARTITION BY city ORDER BY year) / avg_sale_price) - 1) * 100) as rate
    FROM average_sale_price
)
SELECT city, ROUND(AVG(rate),2) avg_rate
FROM rate
GROUP BY city;