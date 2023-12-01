CREATE TABLE pubs (
pub_id INT PRIMARY KEY,
pub_name VARCHAR(50),
city VARCHAR(50),
state VARCHAR(50),
country VARCHAR(50)
);
--------------------
-- Create the 'beverages' table
CREATE TABLE beverages (
beverage_id INT PRIMARY KEY,
beverage_name VARCHAR(50),
category VARCHAR(50),
alcohol_content FLOAT,
price_per_unit DECIMAL(8, 2)
);
--------------------
-- Create the 'sales' table
CREATE TABLE sales (
sale_id INT PRIMARY KEY,
pub_id INT,
beverage_id INT,
quantity INT,
transaction_date DATE,
FOREIGN KEY (pub_id) REFERENCES pubs(pub_id),
FOREIGN KEY (beverage_id) REFERENCES beverages(beverage_id)
);
--------------------
Create the 'ratings' table CREATE TABLE ratings ( rating_id INT PRIMARY KEY, pub_id INT, customer_name VARCHAR(50), rating FLOAT, review TEXT, FOREIGN KEY (pub_id) REFERENCES pubs(pub_id) );
--------------------
-- Insert sample data into the 'pubs' table
INSERT INTO pubs (pub_id, pub_name, city, state, country)
VALUES
(1, 'The Red Lion', 'London', 'England', 'United Kingdom'),
(2, 'The Dubliner', 'Dublin', 'Dublin', 'Ireland'),
(3, 'The Cheers Bar', 'Boston', 'Massachusetts', 'United States'),
(4, 'La Cerveceria', 'Barcelona', 'Catalonia', 'Spain');
--------------------
-- Insert sample data into the 'beverages' table
INSERT INTO beverages (beverage_id, beverage_name, category, alcohol_content, price_per_unit)
VALUES
(1, 'Guinness', 'Beer', 4.2, 5.99),
(2, 'Jameson', 'Whiskey', 40.0, 29.99),
(3, 'Mojito', 'Cocktail', 12.0, 8.99),
(4, 'Chardonnay', 'Wine', 13.5, 12.99),
(5, 'IPA', 'Beer', 6.8, 4.99),
(6, 'Tequila', 'Spirit', 38.0, 24.99);
--------------------
INSERT INTO sales (sale_id, pub_id, beverage_id, quantity, transaction_date)
VALUES
(1, 1, 1, 10, '2023-05-01'),
(2, 1, 2, 5, '2023-05-01'),
(3, 2, 1, 8, '2023-05-01'),
(4, 3, 3, 12, '2023-05-02'),
(5, 4, 4, 3, '2023-05-02'),
(6, 4, 6, 6, '2023-05-03'),
(7, 2, 3, 6, '2023-05-03'),
(8, 3, 1, 15, '2023-05-03'),
(9, 3, 4, 7, '2023-05-03'),
(10, 4, 1, 10, '2023-05-04'),
(11, 1, 3, 5, '2023-05-06'),
(12, 2, 2, 3, '2023-05-09'),
(13, 2, 5, 9, '2023-05-09'),
(14, 3, 6, 4, '2023-05-09'),
(15, 4, 3, 7, '2023-05-09'),
(16, 4, 4, 2, '2023-05-09'),
(17, 1, 4, 6, '2023-05-11'),
(18, 1, 6, 8, '2023-05-11'),
(19, 2, 1, 12, '2023-05-12'),
(20, 3, 5, 5, '2023-05-13');
--------------------
-- Insert sample data into the 'ratings' table
INSERT INTO ratings (rating_id, pub_id, customer_name, rating, review)
VALUES
(1, 1, 'John Smith', 4.5, 'Great pub with a wide selection of beers.'),
(2, 1, 'Emma Johnson', 4.8, 'Excellent service and cozy atmosphere.'),
(3, 2, 'Michael Brown', 4.2, 'Authentic atmosphere and great beers.'),
(4, 3, 'Sophia Davis', 4.6, 'The cocktails were amazing! Will definitely come back.'),
(5, 4, 'Oliver Wilson', 4.9, 'The wine selection here is outstanding.'),
(6, 4, 'Isabella Moore', 4.3, 'Had a great time trying different spirits.'),
(7, 1, 'Sophia Davis', 4.7, 'Loved the pub food! Great ambiance.'),
(8, 2, 'Ethan Johnson', 4.5, 'A good place to hang out with friends.'),
(9, 2, 'Olivia Taylor', 4.1, 'The whiskey tasting experience was fantastic.'),
(10, 3, 'William Miller', 4.4, 'Friendly staff and live music on weekends.');



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

select pub_id,P.pub_name as PUB,round(avg(R.rating),2) as avg_rating from ratings R join pubs P using (pub_id)
group by pub_id
order by avg_rating desc
limit 1 OFFSET 0 ;

/*4. What are the top 5 beverages by sales quantity across all pubs? */

select B.beverage_name, sum(S.quantity) as sales_qty From sales S join  beverages B using(beverage_id)
group by beverage_name
order by sales_qty desc
limit 5;

/*5. How many sales transactions occurred on each date? */

select transaction_date, count(sale_id) as transactions from sales
group by transaction_date
order by transaction_date;

/*6. Find the name of someone that had cocktails and which pub they had it in? */

with CTE_category as (select R.pub_id,B.beverage_id, R.customer_name,P.pub_name
from sales S join beverages B using(beverage_id)
join ratings R using(pub_id)
join pubs P using (pub_id)
where category = 'Cocktail')

select pub_id,customer_name,pub_name from CTE_category
order by pub_id;

/*7. What is the average price per unit for each category of beverages, excluding the category 'Spirit'? */

select category,round(avg(price_per_unit),2) from beverages
where category not like 'Spirit'
group by category;

/*8. Which pubs have a rating higher than the average rating of all pubs? */

select P.pub_id,P.pub_name,round(avg(R.rating),2) as avg_rating from pubs P join ratings R using (pub_id)
group by pub_id
having avg_rating > (select round(avg(rating),2) from ratings) 
;
/*9. What is the running total of sales amount for each pub, ordered by the transaction date? */

select pub_id,pub_name,transaction_date,
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

,CTE2 as(select P.country, 
round(avg(B.price_per_unit),2) as overall_avg from sales S
   JOIN
    pubs P USING (pub_id)
        JOIN
    beverages B USING (beverage_id)
group by country)

select  CTE1.country, CTE1.category, CTE1.avg_per_unit,CTE2.overall_avg from CTE1 join CTE2
using(country)
order by country,category;

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




