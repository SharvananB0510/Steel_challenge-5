/*1. How many pubs are located in each country?  */

SELECT 
    country, COUNT(pub_id) AS no_of_pubs
FROM
    pubs
GROUP BY country;

/*2. What is the total sales amount for each pub, including the beverage price and quantity sold? */

with sales_qtty as (SELECT 
    (S.quantity * B.price_per_unit) as amount , P.pub_name
FROM
    Sales S
        JOIN
    beverages B USING (beverage_id)
        JOIN
    pubs P USING (pub_id)
)

SELECT 
    pub_name AS PUB, SUM(amount) AS Sales_amount
FROM
    sales_qtty
GROUP BY PUB
ORDER BY Sales_amount DESC;
 
/*3. Which pub has the highest average rating? */

SELECT 
    pub_id,
    P.pub_name AS PUB,
    ROUND(AVG(R.rating), 2) AS avg_rating
FROM
    ratings R
        JOIN
    pubs P USING (pub_id)
GROUP BY pub_id
ORDER BY avg_rating DESC
LIMIT 1;

/*4. What are the top 5 beverages by sales quantity across all pubs? */

SELECT 
    B.beverage_name, SUM(S.quantity) AS sales_qty
FROM
    sales S
        JOIN
    beverages B USING (beverage_id)
GROUP BY beverage_name
ORDER BY sales_qty DESC
LIMIT 5;

/*5. How many sales transactions occurred on each date? */

SELECT 
    transaction_date, COUNT(sale_id) AS transactions
FROM
    sales
GROUP BY transaction_date
ORDER BY transaction_date;

/*6. Find the name of someone that had cocktails and which pub they had it in? */

with CTE_category as (SELECT 
    R.pub_id, B.beverage_id, R.customer_name, P.pub_name
FROM
    sales S
        JOIN
    beverages B USING (beverage_id)
        JOIN
    ratings R USING (pub_id)
        JOIN
    pubs P USING (pub_id)
WHERE
    category = 'Cocktail')

SELECT 
    pub_id, customer_name, pub_name
FROM
    CTE_category
ORDER BY pub_id;

/*7. What is the average price per unit for each category of beverages, excluding the category 'Spirit'? */

SELECT 
    category, ROUND(AVG(price_per_unit), 2)
FROM
    beverages
WHERE
    category NOT LIKE 'Spirit'
GROUP BY category;

/*8. Which pubs have a rating higher than the average rating of all pubs? */

SELECT 
    P.pub_id, P.pub_name, ROUND(AVG(R.rating), 2) AS avg_rating
FROM
    pubs P
        JOIN
    ratings R USING (pub_id)
GROUP BY pub_id
HAVING avg_rating > (SELECT 
        ROUND(AVG(rating), 2)
    FROM
        ratings);
/*9. What is the running total of sales amount for each pub, ordered by the transaction date? */

SELECT  pub_id,
	 pub_name,
     transaction_date,
(S.quantity* B.price_per_unit) as sales_amount,
sum(S.quantity * B.price_per_unit) over(partition by pub_id order by transaction_date) as running_total
from sales S
join beverages B using (beverage_id)
join pubs P using (pub_id)
order by pub_id,transaction_date; 

/*10. For each country, what is the average price per unit of beverages in each category, and what is the overall average price per unit of beverages across all categories?*/

with CTE1 as (SELECT 
    P.country, B.category, ROUND(AVG(B.price_per_unit), 2) as avg_per_unit
FROM
    sales S
        JOIN
    pubs P USING (pub_id)
        JOIN
    beverages B USING (beverage_id)
GROUP BY country , category)

,CTE2 as(SELECT 
    P.country, ROUND(AVG(B.price_per_unit), 2) AS overall_avg
FROM
    sales S
        JOIN
    pubs P USING (pub_id)
        JOIN
    beverages B USING (beverage_id)
GROUP BY country)

SELECT 
    CTE1.country,
    CTE1.category,
    CTE1.avg_per_unit,
    CTE2.overall_avg
FROM
    CTE1
        JOIN
    CTE2 USING (country)
ORDER BY country , category;

/*11. For each pub, what is the percentage contribution of each category of beverages to the total sales amount, and what is the pub's overall sales amount?*/

with Overall_sales as(
SELECT 
    P.pub_id,
    P.pub_name,
    SUM(B.price_per_unit * S.quantity) AS Overall_Sales
FROM
    Sales S
        JOIN
    beverages B USING (beverage_id)
        JOIN
    pubs P USING (pub_id)
GROUP BY pub_id , pub_name)
,categ_sales as (
SELECT 
    P.pub_name,
    B.category,
    SUM(B.price_per_unit * S.quantity) AS categ_Sales
FROM
    Sales S
        JOIN
    beverages B USING (beverage_id)
        JOIN
    pubs P USING (pub_id)
GROUP BY P.pub_name , B.category
)
SELECT 
    O.pub_id,
    O.pub_name,
    O.Overall_sales,
    C.category,
    C.categ_Sales,
    ROUND((C.categ_Sales / O.Overall_sales) * 100,
            2) AS percentage_contribution
FROM
    Overall_sales O
        JOIN
    categ_sales C ON C.pub_name = O.pub_name
GROUP BY O.pub_id , O.pub_name , O.Overall_sales , C.category;
