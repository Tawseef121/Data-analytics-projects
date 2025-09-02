-- Task Describe the Tables--
desc customers;
desc products;
desc orders;
desc orderdetails;
-- Identify the top 3 cities with the highest number of customers to determine key market
-- for targeted marketing and logistic optimization.
-- Hint: Use the “Customers” Table.
-- Return the result table limited to top 3 locations in descending order
-- Note: NUM in the output format denotes a numerical value
select location,count(*) as number_of_customers
from customers 
group by location
order by number_of_customers desc limit 3;
-- Determine the distribution of customers by the number of orders placed. 
-- This insight will help in segmenting customers into one-time buyers,
-- occasional shoppers, and regular customers for tailored marketing strategies.
-- Hint: Use the “Orders” table.
-- Return the result table which helps you to segment customers on the basis of 
-- the number of orders in ascending order.
-- Note: NUM in the output format denotes a numerical value
SELECT NumberOfOrders, COUNT(*) AS CustomerCount
FROM (
 SELECT customer_id, COUNT(order_id) AS NumberOfOrders
 FROM Orders
 GROUP BY customer_id
) AS CustomerOrders
GROUP BY NumberOfOrders
ORDER BY NumberOfOrders ASc;
-- Identify products where the average purchase quantity per order is 2 but with a high total revenue,
-- suggesting premium product trends.
-- Hint: Use “OrderDetails”.
-- Return the result table which includes average quantity and the total revenue in descending order.
-- Note: NUM in the output format denotes a numerical value.

Select Product_Id,
    Avg(Quantity) as AvgQuantity ,
sum(Quantity*Price_per_unit) as TotalRevenue
From orderdetails
group by Product_Id
Having AvgQuantity=2
order by TotalRevenue desc;

-- For each product category, calculate the unique number of customers purchasing from it. 
-- This will help understand which categories have wider appeal across the customer base.


-- Hint: Use the “Products”, “OrderDetails” and “Orders” table.
-- Return the result table which will help you count the unique number of customers in descending order.
-- Note: NUM in the output format denotes a numerical value.
select p.category,
count(distinct O.customer_id) as unique_customers
from products p
join orderdetails OD on p.product_id=OD.product_id
join orders O on OD.order_id=O.order_id
Group by p.category
order by Unique_customers;

-- Analyze the month-on-month percentage change in total sales to identify growth trends.
-- Hint: Use the “Orders” table.
-- Return the result table which will help you get the month (YYYY-MM), 
-- Total Sales and Percent Change of the total amount
-- (Present month value- Previous month value/ Previous month value)*100.
-- The resulting change in percentage should be rounded to 2 decimal places.
WITH MonthlySales AS (
    SELECT 
        DATE_FORMAT(Order_Date, '%Y-%m') AS Month,
        SUM(Total_Amount) AS TotalSales
    FROM Orders
    GROUP BY DATE_FORMAT(Order_Date, '%Y-%m')
),
SalesWithLag AS (
    SELECT 
        Month,
        TotalSales,
        LAG(TotalSales) OVER (ORDER BY Month) AS PrevMonthSales
    FROM MonthlySales
)
SELECT 
    Month,
    TotalSales,
    ROUND(
        CASE 
            WHEN PrevMonthSales IS NULL OR PrevMonthSales = 0 THEN NULL
            ELSE ((TotalSales - PrevMonthSales) * 100.0 / PrevMonthSales)
        END,
        2
    ) AS PercentChange
FROM SalesWithLag;

-- Examine how the average order value changes month-on-month. 
-- Insights can guide pricing and promotional strategies to enhance order value.
-- Hint: Use the “Orders” Table.
-- Return the result table which will help you get the month (YYYY-MM), 
-- Average order value and Change in the average order value (Present month value- Previous month value).
-- The resulting change in average order value should be rounded to 2 decimal places and should be ordered in descending order.
-- Note: DECI NUM in the output format denotes a numerical value with decimal.
WITH MonthlyAvg AS (
    SELECT 
        DATE_FORMAT(Order_Date, '%Y-%m') AS Month,
        AVG(Total_Amount) AS AvgOrderValue
    FROM Orders
    GROUP BY DATE_FORMAT(Order_Date, '%Y-%m')
),
WithLag AS (
    SELECT 
        Month,
        AvgOrderValue,
        LAG(AvgOrderValue) OVER (ORDER BY Month) AS PrevAvg
    FROM MonthlyAvg
)
SELECT 
    Month,
    AvgOrderValue,
    ROUND(
        IFNULL(AvgOrderValue - PrevAvg, NULL),
        2
    ) AS ChangeInValue
FROM WithLag
ORDER BY ChangeInValue desc;
-- Based on sales data, identify products with the fastest turnover rates,
-- suggesting high demand and the need for frequent restocking.
-- Hint: Use the “OrderDetails” table.
-- Return the result table limited to top 5 product according to 
-- the SalesFrequency column in descending order.
select Product_id,
Count(*) as SalesFrequency
from orderdetails
group by Product_id
order by SalesFrequency desc
limit 5;
-- List products purchased by less than 40% of the customer base, 
-- indicating potential mismatches between inventory and customer interest.
-- Hint: Use the “Products”, “Orders”, “OrderDetails” and “Customers” table.
-- Return the result table which will help you get the product names along with 
-- the count of unique customers who belong to the lower 40% of the customer pool.
-- Note: NUM in the output format denotes a numerical value and Product name denote name of the product.
WITH TotalCustomers AS (
    SELECT COUNT(DISTINCT customer_id) AS total_customers
    FROM Customers
),
ProductCustomerCount AS (
    SELECT 
        od.product_id,
        p.name,
        COUNT(DISTINCT o.customer_id) AS UniqueCustomerCount
    FROM OrderDetails od
    JOIN Orders o ON od.order_id = o.order_id
    JOIN Products p ON od.product_id = p.product_id
    GROUP BY od.product_id, p.name
)
SELECT 
    pcc.product_id,
    pcc.name,
    pcc.UniqueCustomerCount
FROM ProductCustomerCount pcc
JOIN TotalCustomers tc
ON 1 = 1
WHERE pcc.UniqueCustomerCount < tc.total_customers * 0.4;
-- Evaluate the month-on-month growth rate in the customer base to understand 
-- the effectiveness of marketing campaigns and market expansion efforts.
-- Hint: Use the “Orders” table.
-- Return the result table which will help you get the count of 
-- the number of customers who made the first purchase on monthly basis.
-- The resulting table should be ascendingly ordered according to the month
with Firstpurchases as(
    select customer_id,
    min(order_date) as Firstorderdate
    from orders
    Group by customer_id
)
select Date_Format(Firstorderdate,'%Y-%m') as
 FirstPurchaseMonth,
 count(customer_id) as TotalNewCustomers
 from Firstpurchases
 Group by FirstPurchaseMonth
 order by FirstPurchaseMonth asc;
-- Identify the months with the highest sales volume, aiding in planning for stock levels, 
-- marketing efforts, and staffing in anticipation of peak demand periods.
-- Hint: Use the “Orders” table.
-- Return the result table which will help you get the month (YYYY-MM)
-- and the Total sales made by the company limiting to top 3 months.
-- The resulting table should be in descending order suggesting the highest sales month.
select 
Date_Format(order_date,'%Y-%m') as Month,
sum(Total_amount) as TotalSales
from orders
Group by Month 
order by Month desc


