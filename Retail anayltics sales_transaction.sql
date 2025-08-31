-- Data Cleaning

-- Remove Duplicate Transactions
-- Write a query to identify the number of duplicates in sales_transaction. Also, create a separate table 
-- containing the unique values and remove the the original table from the databases and replace the name 
-- of the new table with the original name.

-- Hint:
-- 1. Get Duplicates from sales_transaction 
-- Pull TransactionID and count of rows from table having COUNT(*)>1
select ﻿TransactionID, count(*) as row_counts
from sales_transaction
-- where ﻿TransactionID = 4999 
group by ﻿TransactionID
having row_counts > 1;

-- 2. selecting only distinct entries
-- create table new_table as distinct rows from sales_transaction
create table sales_transaction_temp as
select distinct * from sales_transaction;

select ﻿TransactionID, count(*) row_counts
from sales_transaction_temp
group by ﻿TransactionID
having row_counts > 1;

-- 3. DELETING table with duplicates
-- drop table old table name
drop table if exists sales_transaction;

-- 4. renaming table with distinct table to original table
-- alter table new table rename to old table name
alter table sales_transaction_temp
rename to sales_transaction;

select count(*) from sales_transaction;

-- Identify and Fix Incorrect Prices in Sales Transactions
-- 1. Write a query to identify the discrepancies in the price of the same product in “sales_transaction” 
-- and "product_inventory". Also, update those discrepancies to match the price in both the tables.
-- Hint:
-- Pull productID, TransactionID, TransactionPrice and InventoryPrice from sales_transaction 
-- joining product_inventory on ProductID WHERE st.Price <> pi.Price
select s.productid, s.﻿TransactionID, s.price as transactionprice, p.price as inventoryprice
from sales_transaction as s
inner join product_inventory as p
on s.productid = p.﻿ProductID
where s.price != p.price;

-- 2. Then, update the sales transactions to match the inventory prices where discrepancies are found.
-- Hint:
-- UPDATE table1 
-- SET column = ( SELECT table2.column FROM table2 WHERE table1.common_column = table2.common_column ) 
-- WHERE table1.common_column IN 
-- (SELECT common_column FROM table2 WHERE table1.column <> table2.column)
update sales_transaction s
set s.price = (select p.price from product_inventory p where s.productid = p.﻿ProductID)
where s.productid in
(select productid from product_inventory p where s.price != p.price);

-- To identify nulls values in the dataset and then replace it by ‘Unknown’

-- 1. Count rows where location is null in customer profile
select * from customer_profiles;

select count(*) from customer_profiles
where location is null;

select count(*) 
from customer_profiles
where location = "";

-- 2. Wherever null, update to "Unknown"
-- Hint:
-- UPDATE table
-- SET column = “Unknown” or 
-- (SELECT AVG(col) FROM table) or
-- (SELECT col FROM table GROUP BY col ORDER BY COUNT(*) DESC LIMIT 1)
-- WHERE column IS NULL

-- For Location
-- Imputation with a String
update customer_profiles
set location = "Unknown" where location = "";

select * from customer_profiles
where location = "Unknown";

select distinct location
from customer_profiles;

-- Imputation with Mode
select location, count(*)
from customer_profiles
group by location
order by count(*) desc;

select location from customer_profiles group by location order by count(*) desc limit 1;

create table customer_profiles_temp as
select * from customer_profiles;

update customer_profiles
set location = (select location from customer_profiles_temp group by location order by count(*) desc limit 1)
where location = "Unknown";

select distinct location
from customer_profiles;

select count(*)
from customer_profiles
where location = "West";

drop table if exists customer_profiles_temp;

-- Imputation with mean
select * from sales_transaction;

select count(*)
from sales_transaction
where price = 69;

create table sales_transaction_temp as 
select * from sales_transaction;

select round(avg(price),2)
from sales_transaction_temp;

update sales_transaction
set price = (select round(avg(price),2) from sales_transaction_temp)
where price = 69;

select count(*)
from sales_transaction
where price = 69;

select * from sales_transaction;

drop table if exists sales_transaction_temp;

-- Last cleaning is CASTING to DATE in Sales_transaction file
-- Write a SQL query to clean the DATE column in the dataset.
-- Hint:
-- 1. Change col from text to date
-- ALTER TABLE table
-- MODIFY COLUMN col DATE;
select * from sales_transaction;

alter table sales_transaction
modify column transactiondate date;

select * from sales_transaction;

select * from customer_profiles;

alter table customer_profiles
modify column joindate date;

select * from customer_profiles;

-- 2. Change from str to date
-- UPDATE your_table
-- SET your_date_column = STR_TO_DATE(REPLACE(date_col, '/', '-'), '%d-%m-%Y');

-- Exploratory Data Analysis (EDA)

-- Get a summary of total sales and quantities sold per product.
-- Write a SQL query to summarize the total sales and quantities sold per product by the company.
-- Hint:
-- Pull productid, sum of quantity purchased and sum of product of Price and Quantity Purchased 
-- from the sales transaction table

select * from sales_transaction;

select productid, 
	   sum(quantitypurchased) as quantities_sold,
       round(sum(quantitypurchased*price),2) as total_sale
from sales_transaction
group by productid
order by productid;
		
-- Customer Purchase Frequency
-- Write a SQL query to count the number of transactions per customer to understand purchase frequency. 
-- Hint:
-- Pull customerid and count of rows from sales transaction
select customerid, count(*) as transaction_counts
from sales_transaction
group by customerid
order by transaction_counts desc
limit 7;

-- Product Categories Performance
-- Write a SQL query to evaluate the performance of the product categories based on the total sales which 
-- help us understand the product categories which needs to be promoted in the marketing campaigns.
-- Hint:
-- Pull Category from product inventory, sum of QuantityPurchased and  
-- sum of product of Price and QuantityPurchased from sales transaction joining on productid. 
select p.category as product_category,
	   sum(s.quantitypurchased) as total_quantity,
       round(sum(s.price*s.quantitypurchased),2) as total_sale
from product_inventory as p
inner join sales_transaction as s
on p.﻿ProductID = s.productid
group by p.category
order by total_sale desc;

-- High Sales Products
-- Write a SQL query to find the top 10 products with the highest total sales revenue from the sales transactions. 
-- This will help the company to identify the High sales products which needs to be focused to increase the revenue 
-- of the company.
-- Hint:
-- Pull productid,sum of product of price and quantity as total sale and pull top 10 products with highest sale
select productid, round(sum(price*quantitypurchased),2) as total_revenue
from sales_transaction
group by productid
order by total_revenue desc
limit 10;

-- Low Sales Products
-- Write a SQL query to find the ten products with the least amount of units sold from the sales transactions, 
-- provided that atleast one unit was sold for those products.
-- Hint:
-- Pull productid,sum of quantity as total quantity sold and pull top 10 products with lowest sale 
select productid, sum(quantitypurchased) as total_units_sold
from sales_transaction
group by productid
having total_units_sold > 0
order by total_units_sold
limit 10;

-- Get the top 5 products from each category in terms of revenue generated
-- Write an SQL query to get top 5 performing products from each category by revenue
-- Hint:
-- Pull productname, category, sum of product of price and quantity as total sale and make use of row number over
-- partitioning by category and order by total sale  descending form product inventory and sales transaction table
select * from
(
select p.productname, p.category,
	   round(sum(s.price*s.quantitypurchased),2) as total_revenue,
       row_number() over(partition by p.category order by sum(s.price*s.quantitypurchased) desc) as product_rank
from sales_transaction as s
join product_inventory as p
on s.productid = p.﻿ProductID
group by p.productname, p.category
) as ranked_products
where product_rank <= 5
order by category, product_rank;

-- Get top 20 percent most ordered products from the entire data.
-- Hint:
-- Pull productname, sum of quantity, ntile of 10 over order by sum of quanity desc.
-- Pull records where ntile is less than equal to 2
select * from
(
select p.productname,
	   sum(s.quantitypurchased) as total_units_sold,
       ntile(10) over(order by sum(s.quantitypurchased) desc) as product_decile
from product_inventory as p
inner join sales_transaction as s
on p.﻿ProductID = s.productid
group by p.productname
) as decile_product
where product_decile <= 2;

-- Sales Trends
-- Write a SQL query to identify the sales trend to understand the revenue pattern of the company.
-- Hint:
-- Pull TransactionDate, count of rows as number of transaction, sum of quantity and sum of product of
-- price and quantity as revenue from sales transaction table ordering descending by date
select transactiondate, 
	   count(*) as number_of_transactions,
       sum(quantitypurchased) as total_units_sold,
       round(sum(price*quantitypurchased),2) as total_revenue
from sales_transaction
group by transactiondate
order by transactiondate desc;

-- Growth rate of sales M-o_M
-- Write a SQL query to understand the month on month growth rate of sales of the company which will help 
-- understand the growth trend of the company.
-- Hint:
-- Create a CTE with Extract month from transactiondate and sum of product of price and quantity as total revenue
-- From the CTE get sale, lag(sale) over ordering by month as previous sale, (sale-previous sale)/previous sale *100
-- as mom growth percentage

-- For Revenue
with monthly_revenue as
(
select extract(month from transactiondate) as transaction_month,
	   round(sum(price*quantitypurchased),2) as total_revenue
from sales_transaction
group by extract(month from transactiondate)
order by transaction_month
)
select transaction_month, total_revenue,
	   lag(total_revenue) over(order by transaction_month) as previous_month_sale,
       round((total_revenue - lag(total_revenue) over(order by transaction_month))*100/lag(total_revenue) over(order by transaction_month),2) as percentage_mom_growth
from monthly_revenue
order by transaction_month;

-- For Quantity Purchase (Home Assignment)
with monthly_units_sold as
(
select extract(month from transactiondate) as transactionmonth,
	   sum(quantitypurchased) as total_units_sold,
       lag(sum(quantitypurchased)) over(order by extract(month from transactiondate)) as previous_total_units_sold
from sales_transaction
group by  extract(month from transactiondate)
order by transactionmonth
)
select transactionmonth,
		total_units_sold,
        previous_total_units_sold,
        ((total_units_sold-previous_total_units_sold)/previous_total_units_sold)*100 as percent_mom_units_growth
from monthly_units_sold
order by transactionmonth;

-- Customers - High Purchase Frequency and Revenue
-- Write a SQL query that describes the number of transaction along with the total amount spent by each 
-- customer which are on the higher side and will help us understand the customers who are the high frequency 
-- purchase customers in the company.
-- Hint:
-- Pull CustomerID, count of rows as number of transactions, sum of product of price and quantity as spend
-- and filter for records having transactions > 10 and spend > 1000
select customerid, 
	   count(*) as number_of_transactions,
	   round(sum(price * quantitypurchased),2) as customer_spend
from sales_transaction
group by customerid
having number_of_transactions > 10 and customer_spend > 1000
order by number_of_transactions desc;

-- Occasional Customers - Low Purchase Frequency
-- Write a SQL query that describes the number of transaction along with the total amount spent by each customer, 
-- which will help us understand the customers who are occasional customers in the company.
-- Hint:
-- Pull CustomerID, count of rows as number of transactions, sum of product of price and quantity as spend
-- and filter for records having transactions <= 2
select customerid,
	   count(*) as number_of_transactions,
       round(sum(price * quantitypurchased), 2) as customer_spend
from sales_transaction
group by customerid
having number_of_transactions <= 2
order by number_of_transactions, customer_spend;

-- Repeat Purchase Patterns
-- Write a SQL query that describes the total number of purchases made by each customer against each productID 
-- to understand the repeat customers in the company.
-- Hint:
-- Pull CustomerID, ProductID, count of rows as purchase frequency filtering for purchase frequency > 1
select customerid, 
	   productid,
       count(*) as purchase_frequency
from sales_transaction
group by customerid, productid
having purchase_frequency > 1
order by customerid, productid;

-- Loyalty Indicators
-- Write a SQL query that describes the duration between the first and the last purchase of the customer 
-- in that particular company to understand the loyalty of the customer.
-- Hint:
-- Pull CustomerID, min of transaction date as first purchase and max of transaction date as last purchase,
-- difference between first purchase and last purchase as days between purchase and filter for records where
-- days between purchase is > 0
-- If date is in text, use STR_TO_DATE(date_column, '%Y-%m-%d')
select customerid,
	   min(transactiondate) as firstpurchase,
       max(transactiondate) as lastpurchase,
       datediff(max(transactiondate),min(transactiondate)) as days_between_purchase
from sales_transaction
group by customerid
having days_between_purchase > 0
order by days_between_purchase desc;

-- Customer Segmentation based on quantity purchased
-- Write a SQL query that segments customers based on the total quantity of products they have purchased. 
-- Also, count the number of customers in each segment. 
-- Hint:
-- Pull  CustomerID,
-- if TotalQuantity > 30 THEN "High" 
-- else if TotalQuantity in the range 10 AND 30 THEN "Med" 
-- else if TotalQuantity in the range 1 and 10 THEN "Low"
-- Else "None"
-- Total quantity is the sum of quantity purchased group by customerid
select customerid,
	   total_quantity,
       case when total_quantity < 0 then "None"
       
			when total_quantity <= 10 then "Low"
            when total_quantity <= 30 then "Med"
            else "High" 
		end as customer_segment
from
(
select customerid,
	   sum(quantitypurchased) as total_quantity
from sales_transaction
group by customerid
order by total_quantity desc
) customer_quantity_purchased;
