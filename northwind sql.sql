-- The Northwind database is a sample database used by Microsoft to demonstrate the features of some of its products,
-- including SQL Server and Microsoft Access. 
-- The database contains the sales data for Northwind Traders, a fictitious specialty foods exportimport company.

-- Let's get to know the data
select * from orders
-- total number of rows in orders table : 830

select count(distinct order_id) from orders        
-- distinct order count : 830

select count(distinct customer_id) from orders 
-- total customers: 89

select count(distinct employee_id) from orders      
-- total employees: 9

select max(order_date), min(order_date) from orders 
-- order dates between: 1996.07.04 - 1998.05.06


select distinct(ship_via) from orders               
-- total shippers: 3

select distinct ship_country from orders     
-- orders shipped to 21 countries

select  distinct ship_city from orders 
-- orders shipped to 70 cities

select min(freight), max(freight) from orders
-- freight costs between  0.02  and 1007.64 

select * from order_details                         
-- order_details table has 2155 rows 

select distinct order_id from order_details
-- totally 830 orders

select count(distinct product_id) from order_details 
-- totally 77 products

select product_id, count(distinct unit_price) from order_details group by 1   
-- all products have 2 or 3 different prices

select sum(quantity) from order_details
-- totally 51317 products have been sold

select min(unit_price), max(unit_price) from order_details
-- min unit price: 2, max unit price 263.5 

select * from customers
-- customers table has 91 rows

select distinct contact_title from customers
-- customers have 12 different titles

select customer_id from orders
except
select customer_id from customers
-- There are 91 different customers (89 of these customers are mentioned in the order table,
-- There are no customers in the order table but not in the customers table)

select customer_id from customers
except
select customer_id from orders
-- 2 customers are in the customer table but they do not have any orders,
-- these are customers with customer_id FISSA and PARIS)


select distinct country from customers              
-- customers from 21 countries

select distinct city from customers
-- customers from 69 cities (not same as orders table)

select  distinct ship_city from orders
except 
select distinct city from customers
-- orders go to 70 different cities, only 1 city (Colchester)
-- orders table have it but customers table don't have it

with cities as (select  o.ship_city, c.city, 
				case
				when o.ship_city = c.city then 1
				else 0 
				end
				as same
				from orders as o
left join customers as c using (customer_id))
select  ship_city, city from cities where same=0
-- a total of 13 records were ordered from London, the order was delivered to Colchester

select * from orders where ship_city = 'Colchester'
-- All of these orders belong to the customer with customer_id "Arout"

select * from shippers                              
-- There are 6 shippers in total, but only 3 of them used for shipping.

select * from employees
-- Totally 9 employees (same with orders table)

select distinct title from employees
-- 4 titles for 9 employees

select employee_id, title, reports_to, country from employees
-- Sales vice President in USA, 5 reports to it,
-- sales manager in UK, 3 reports to it
-- Sales Manager reports to Sales Vice President
-- The company is probably a USA based company

select count(*) from products                       
-- There are 77 products (same as in order details table)

select distinct supplier_id from products
-- These products are sourced from 29 different suppliers

select distinct category_id, count(*) from products group by 1 order by 2
-- There are 8 different product categories, the most products are in category 3

select product_id from products where unit_in_stock= 0
-- 5 products are out of stock: 5-17-29-31-53

select product_id from products where discontinued= 1
-- below products will not be able to ordered again- can not be supplied any more
-- 1, 2, 5, 9, 17, 24, 28, 29, 42, 53

select product_id from products where discontinued = 1 and unit_in_stock=0
-- Among these, 5, 17, 29 and 53 are out of stock.
-- Only product with id_31 can be supplied but it is out of stock

select count(product_id) from products where unit_in_stock <= reorder_level
-- The products returned as a result of the query are at or below the re-order level.

select * from suppliers                      
-- there are 29 suppliers

select count(distinct country) as countries, count(distinct city) as cities from suppliers
-- supplied from 16 countries and 29 cities
-- customers from 21 countries and 69 cities

select * from categories
-- products have 8 categories (same as product table)

select * from employeeterritories
select distinct territory_id from employeeterritories
-- for 9 employees there are 49 territory_id 

select distinct territory_id from territories
-- in territories table there are 53 territory_id

select territory_id from territories
except
select territory_id from employeeterritories
-- 4 territory_id not in employeeterritories table : "72716" , "75234" , "78759" ,"29202"

select territory_id from employeeterritories
except
select territory_id from territories
-- no territory_id in employeeterritories but not in territories

select distinct region_id from territories
-- 4 regions in territories

select * from region
-- same 4 region in regin table

-- ---- 1. SALES ANALYSIS---

-- NUMBER OF ORDERS, NUMBER OF PRODUCTS, SALES REVENUE BY MONTH
select to_char(order_date, 'yy-mm') as "ORDER MONTH",
count(o.order_id) as "number of orders",
sum(quantity) as "number of products",
sum(unit_price*quantity*(1-discount)) as "sales revenue",
sum(unit_price*quantity*(1-discount))/sum(quantity) as "revenue per product"
from orders as o
inner join order_details as od
using(order_id)
group by 1
order by 1
-- There is a general increase in the number of orders over time, but serious activity has started since December 1997.
It can be said that it happened since February 1998. Although the number of orders decreased, revenue and revenue per product increased.
-- It should be noted that although the last month seems low, it is actually a good sales figure since the first 6 days are included.
-- small differences between product quantities and order numbers show themselves in sales revenue and income per product
-- Another remarkable situation is that the revenue per product has increased significantly over the months (except for the last month).
-- Especially in 1998, there was a serious upward trend in all areas such as the number of orders, number of products, sales revenue and income per product.


-- NUMBER OF ORDERS BY DAYS OF THE WEEK
select to_char(order_date, 'day') as "order day",
count(o.order_id) as "number of orders",
sum(quantity) as "number of products",
sum(unit_price*quantity*(1-discount)) as "sales revenue",
sum(unit_price*quantity*(1-discount))/sum(quantity) as "revenue per product"
from orders as o
inner join order_details as od
using(order_id)
group by 1
order by 2
-- While the highest quantities of orders and products are reached on Wednesdays and the lowest quantities 
-- are reached on Mondays, the opposite situation is observed in terms of revenue per product, that is, 
-- while more units of cheap products are sold on Wednesdays, fewer units of relatively expensive products
-- are sold on Mondays. In line with this data, special campaigns can be considered for the day.

--  ----- 2. PRODUCT ANALYSIS ----

-- Let's remember the results we reached while getting to know the data
-- 5 items out of stock: 5-17-29-31-53
-- The products whose product_id is given will not be continued/cannot be supplied.
-- 1, 2, 5, 9, 17, 24, 28, 29, 42, 53
-- Among these, 5, 17, 29 and 53 are out of stock.
-- Only product with id_31 can be supplied but it is out of stock

-- RATIO OF PRODUCTS BELOW REORDER LEVEL
with order_situation  as (select product_id,
unit_in_stock,
reorder_level,
case
when unit_in_stock > reorder_level then 1 else 0 end as HIGH_STOCK,
case 
when unit_in_stock <= reorder_level then 1 else 0 end as LOW_STOCK
from products)
select sum(LOW_STOCK) as BELOW_STOCK_LEVEL,
sum(HIGH_STOCK) as ENOUGH_STOCK,
sum(LOW_STOCK)*100/count(*) as "understock rate %" 
from order_situation
-- As can be seen from the query, under-stock products have reached a very high rate of 28%
-- It should be investigated why this rate is so high

-- ARE OUT OF STOCK PRODUCTS CAUSED BY SPECIFIC SUPPLIERS?

select supplier_id,
count(product_id)
from products where unit_in_stock<=reorder_level
group by 1
order by 2 desc, 1 asc
-- No prominent suppliers due to stock shortage

-- ARE OUT OF STOCK PRODUCTS CONCENTRATED IN CERTAIN CATEGORIES?

select category_id,
count(product_id)
from products where unit_in_stock<=reorder_level
group by 1
order by 2 desc, 1 asc
-- There is no category that stands out due to stock shortage


-- IS THERE ANY PRODUCT THAT IS A BEST SELLING BUT OUT OF STOCK?

select product_id ,
sum(quantity) as sales_quantity
from order_details 
WHERE product_id in (5, 17, 29, 31,53)
group by 1
order by 2 desc
--The first thing we noticed was that the products with id_31 and 17 were out of stock even though they sold well...
-- urgent action needed

select avg(discount*100) from order_details
--  Average discount for all products is 5.61%
select sum(discount)*100/count(order_id) from order_details
-- avg() does not count zero values, so the above query was made, but it turned out that whether the non-discounted 
-- items were included or not, the average caused a very small change in the fractions.


-- PRODUCT BASED NUMBER OF ORDERS, NUMBER OF SALES, SALES REVENUE AND AVERAGE DISCOUNT PERCENTAGE

select product_id ,
count(order_id) as order_quantity,
sum(quantity) as sales_quantity,
sum(unit_price*quantity*(1-discount))::integer as sales_revenue,
avg(discount)*100 as avg_disc_perc
from order_details 
group by 1
order by 4 desc
limit 10

-- ARE THERE PRODUCTS THAT DO NOT HAVE GOOD SALES EVEN IF THE DISCOUNT RATE IS HIGH?
-- (TOP 10 ON SALE, LAST 20 ON SALE)

with top_20 as 
(select product_id,
sum(quantity) as sales_quantity
from order_details
group by 1
order by 2 asc
limit 20),
bottom_10 as
(select product_id, avg(discount)*100 as "discount rate"
from order_details group by 1
order by 2 desc 
limit 10)
select * from top_20
inner join bottom_10
using(product_id)
-- The marketing strategy for these products should be reviewed.
-- (of course, the query could have been, for example, the first 20 on sale or the last 15 on sale, 
-- it was just a way we followed to identify the products that we thought were not worth the discount, 
-- without keeping the range too wide)

-- The result of the following 2 queries: While the unit_price in the products table is the last sales price
--of the product, at least 2 different prices appear for each product in the unit_price column 
-- in the order_details table.

select product_id, unit_price, dense_rank() over(partition by product_id order by unit_price) from order_details
select product_id, unit_price from products

-- WHAT ARE THE FIRST PRICE, THE SECOND PRICE, THE THIRD PRICE, IF ANY, 
-- AND THEIR FIRST ORDER DATES FOR EACH PRODUCT?

with empties as (
	with all_prices as (
	select product_id, unit_price, o.order_date,
	lag(unit_price) over(partition by product_id order by order_date) as previous_price
	from order_details as od
	left join orders as o using(order_id)
	order by 1,3
)
select product_id,
case
when previous_price is null then unit_price
when previous_price!= unit_price then unit_price
end as price,
case
when previous_price is null then order_date
when previous_price != unit_price then order_date
end as price_date
from all_prices
order by 1,3
)
select * from empties where price is not null

-- HOW MANY DAYS AFTER THE PRODUCTS STARTED TO BE SOLD AFTER THE FIRST ORDER DATE IN THE ORDER TABLE, 1996-07-04?
-- 1996/07/04 may not be the starting date, but this date was chosen to get a starting point

with firsts as (
	select product_id, min(order_date) as "first order date" from order_details as od
inner join orders as o using(order_id)
group by 1
order by 1
)
select *, "first order date" - '1996-07-04' as "days passed"
from firsts
order by 3

-- The query result is important because there are products that start to be sold on the first order date (assume the company's first day), and there are also products that start to be sold 100-150 or even 201 days later.
-- It is necessary to take these into consideration when making decisions about products.
-- Top 5 product ids with the lowest sales quantity: 9-15-37-48-67

-- ARE THE REASON FOR THE LOW SALES QUANTITIES BECAUSE OF BEING THEIR LATE SALES?

with firsts as (
	select product_id, min(order_date) as "first order date" from order_details as od
inner join orders as o using(order_id)
group by 1
order by 1
)
select *, "first order date" - '1996-07-04' as "days passed"
from firsts
where product_id in(9,15,37,48,67)
order by 3
-- As can be seen, products with id_9 and 48 may have sold less because they started selling 6-7 months late.
-- If so, it is necessary to focus on products with id_37,15 and 67

-- THE PRODUCTS WITH HIGH DISCOUNT, BAD SALE WERE PRODUCTS WITH ID 9, 48 AND 25
-- MAY IT BE RELATED TO THE TIME THESE PRODUCTS ARE ON SALE?

with firsts as (
	select product_id, min(order_date) as "first order date" from order_details as od
inner join orders as o using(order_id)
group by 1
order by 1
)
select *, "first order date" - '1996-07-04' as "days passed"
from firsts
where product_id in(9,25,48)
order by 3
-- As can be seen from this query, the low sales of product with ID:15 despite the discount
-- cannot be explained by the sales start date.

-- NUMBER OF DAYS THE PRODUCTS ARE ON SALE, TOTAL SALES AND COMPARISON OF DAILY SALES ACCORDINGLY

with day_count as(
	with days as (
	select product_id, min(order_date) as "first order date" from order_details as od
inner join orders as o using(order_id)
group by 1
order by 1
)
select *,  '1998-05-07' - "first order date"  as "day count"
from days
order by 3
),
sales_quantity as(
	select product_id ,
	sum(quantity) as sales_quantity
		from order_details 
		group by 1
		order by 2 desc
)
select sa.product_id,
sales_quantity,
row_number() over(order by sales_quantity desc) as sales_quantity_order,
row_number() over(order by sales_quantity*1.0 /"day count"*1.0 desc) as avg_daily_sales_order,
round((sales_quantity*1.0 /"day count"*1.0), 4) as "avg_daily_sales",
"day count"
from sales_quantity as sa
inner join 
day_count as gs
using(product_id)
order by 2 desc

--This query clearly shows that, whether we rank the products according to their total sales numbers or 
-- their daily average sales numbers, there are no noticeable differences (except for 1-2 products; such as 26 and 61 id),
-- that is, the time it goes on sale, which we mentioned before, is the product's most or not. 
-- It does not directly affect the fact that it sold less


--   3 -- CUSTOMER ANALYSIS --

-- WHAT ARE CUSTOMERS' R-F-M SCORES?
select c.customer_id,
'1998-05-06' - max(order_date) as R,
case
when '1998-05-06' - max(order_date) between 0 and 7 then '5'
when '1998-05-06' - max(order_date) between 8 and 21 then '4'
when '1998-05-06' - max(order_date) between 22 and 45 then '3'
when '1998-05-06' - max(order_date) between 46 and 100 then '2'
else '1' end as recency_point,
count(distinct o.order_id) as F,
case
when count(distinct o.order_id) between 1 and 5 then '1'
when count(distinct o.order_id) between 6 and 8 then '2'
when count(distinct o.order_id) between 9 and 12 then '3'
else '4' end as freq_point,
sum(od.unit_price*quantity*(1-discount))::integer as M,
case
when sum(od.unit_price*quantity*(1-discount)) < 3000 then '1'
when sum(od.unit_price*quantity*(1-discount)) between 3000 and 6000 then '2'
when sum(od.unit_price*quantity*(1-discount)) between 6000.1 and 15000 then '3'
else '4' end as monetary_point
from orders as o
inner join order_details as od using(order_id)
inner join customers as c using(customer_id)
group by 1
order by 2, 4, 7 desc

-- CUSTOMERS' R*F*M SCORES

with all_data as(
select c.customer_id,
'1998-05-06' - max(order_date) as R,
case
when '1998-05-06' - max(order_date) between 0 and 7 then 5
when '1998-05-06' - max(order_date) between 8 and 21 then 4
when '1998-05-06' - max(order_date) between 22 and 45 then 3
when '1998-05-06' - max(order_date) between 46 and 100 then 2
else 1 end as recency_point,
count(distinct o.order_id) as F,
case
when count(distinct o.order_id) between 1 and 5 then 1
when count(distinct o.order_id) between 6 and 8 then 2
when count(distinct o.order_id) between 9 and 12 then 3
else 4 end as freq_point,
sum(od.unit_price*quantity*(1-discount))::integer as M,
case
when sum(od.unit_price*quantity*(1-discount)) < 3000 then 1
when sum(od.unit_price*quantity*(1-discount)) between 3000 and 6000 then 2
when sum(od.unit_price*quantity*(1-discount)) between 6000.1 and 15000 then 3
else 4 end as monetary_point
from orders as o
inner join order_details as od using(order_id)
inner join customers as c using(customer_id)
group by 1
order by 4
)
select customer_id,
recency_point *freq_point *monetary_point as rfm_score
from all_data
order by 2 desc

-- CUSTOMER NUMBER ACCORDING TO R-F-M SCORES

with rfm as (
select c.customer_id,
'1998-05-06' - max(order_date) as R,
case
when '1998-05-06' - max(order_date) between 0 and 7 then '5'
when '1998-05-06' - max(order_date) between 8 and 21 then '4'
when '1998-05-06' - max(order_date) between 22 and 45 then '3'
when '1998-05-06' - max(order_date) between 46 and 100 then '2'
else '1' end as recency_point,
count(distinct o.order_id) as F,
case
when count(distinct o.order_id) between 1 and 5 then '1'
when count(distinct o.order_id) between 6 and 8 then '2'
when count(distinct o.order_id) between 9 and 12 then '3'
else '4' end as freq_point,
sum(od.unit_price*quantity*(1-discount))::integer as M,
case
when sum(od.unit_price*quantity*(1-discount)) < 3000 then '1'
when sum(od.unit_price*quantity*(1-discount)) between 3000 and 6000 then '2'
when sum(od.unit_price*quantity*(1-discount)) between 6000.1 and 15000 then '3'
else '4' end as monetary_point
from orders as o
inner join order_details as od using(order_id)
inner join customers as c using(customer_id)
group by 1
order by 4
)
select recency_point,
freq_point,
monetary_point,
count(customer_id)
from rfm
group by 1,2,3
order by 1,2,3

-- There may be customers to focus on here, too. For example, there are customers with R=1 and M= 4 and F=3 or F=4.
-- Or M score is high but R or F is low

-- NUMBER OF CUSTOMERS BY RFM SEGMENTS

with rfm_score as (
with all_data as(
select c.customer_id,
'1998-05-06' - max(order_date) as R,
case
when '1998-05-06' - max(order_date) between 0 and 7 then 5
when '1998-05-06' - max(order_date) between 8 and 21 then 4
when '1998-05-06' - max(order_date) between 22 and 45 then 3
when '1998-05-06' - max(order_date) between 46 and 100 then 2
else 1 end as recency_point,
count(distinct o.order_id) as F,
case
when count(distinct o.order_id) between 1 and 5 then 1
when count(distinct o.order_id) between 6 and 8 then 2
when count(distinct o.order_id) between 9 and 12 then 3
else 4 end as freq_point,
sum(od.unit_price*quantity*(1-discount))::integer as M,
case
when sum(od.unit_price*quantity*(1-discount)) < 3000 then 1
when sum(od.unit_price*quantity*(1-discount)) between 3000 and 6000 then 2
when sum(od.unit_price*quantity*(1-discount)) between 6000.1 and 15000 then 3
else 4 end as monetary_point
from orders as o
inner join order_details as od using(order_id)
inner join customers as c using(customer_id)
group by 1
order by 4
)
select customer_id,
recency_point *freq_point *monetary_point as rfm_score
	from all_data
	order by 2
)
select case
when rfm_score < 8 then '4th class'
when rfm_score between 8 and 19 then '3rd class'
when rfm_score between 20 and 48 then '2nd class'
else '1st class' end as rfm_segment,
count(customer_id) as customer_count
from rfm_score
group by 1
order by 1
-- 17 first class customers, that is 19%, about 1 in 5 customers, I guess it's not a bad rate.
-- But 27 4th class customers, 30.4%, that is, three out of 10 customers, need to be worked on
-- More importantly, second class customers, they are 27, that is, three out of 10 customers.
-- These are 1 low score of R, F or M, or 2 moderate scores. Probably customers who are easy to upgrade to class 1. 
-- This opportunity should be utilized through promotions, price reductions, etc.

-- CUSTOMER ANALYSIS BY R-F SEGMENT

with rf as (
select c.customer_id,
'1998-05-06' - max(order_date) as R,
case
when '1998-05-06' - max(order_date) between 0 and 7 then '5'
when '1998-05-06' - max(order_date) between 8 and 21 then '4'
when '1998-05-06' - max(order_date) between 22 and 45 then '3'
when '1998-05-06' - max(order_date) between 46 and 100 then '2'
else '1' end as recency_point,
count(distinct o.order_id) as F,
case
when count(distinct o.order_id) between 1 and 5 then '1'
when count(distinct o.order_id) between 6 and 8 then '2'
when count(distinct o.order_id) between 9 and 12 then '3'
else '4' end as freq_point
from orders as o
inner join order_details as od using(order_id)
inner join customers as c using(customer_id)
group by 1
order by 4
)
select recency_point,
freq_point,
count(customer_id)
from rf
group by 1,2
order by 1,2
-- This table can be used as follows: R score is 1, meaning he hasn't shopped for a long time, but F is 4,
-- meaning he actually shops frequently. This type of customers can be focused on.

-- WHAT ARE THE TOTAL ORDER AMOUNT OF CUSTOMERS, DIFFERENT PRODUCT QUANTITIES AND ORDER NUMBER?

select o.customer_id, sum(od.unit_price*od.quantity*(1-od.discount))::integer as total_order_amount,
count(distinct od.product_id) as unique_product_count,
count(distinct order_id) as order_count
from orders as o
left join order_details as od using(order_id)
group by 1
order by 2 desc
--order by 3 desc
--order by 4 desc

-- Although there is no one-to-one relationship between the number of different products and monetary return, 
-- product diversification is expected to increase return, so work can be done towards product diversification.


--  4 ---- EMPLOYEE ANALYSIS --

-- TOTAL SALES BY EMPLOYEE, NUMBER OF DIFFERENT PRODUCTS, NUMBER OF ORDERS AND NUMBER OF CUSTOMERS

select o.employee_id, e.title, sum(od.unit_price*od.quantity*(1-od.discount))::integer as total_sales,
count(distinct od.product_id) as unique_product_count,
count(distinct od.order_id) as order_count,
count(distinct o.customer_id) as customer_count
from orders as o
left join order_details as od using(order_id)
left join employees as e using(employee_id)
group by 1,2
order by 3 desc
--order by 3 desc
--order by 4 desc
--order by 5 desc
-- The number of orders and total sales are almost directly proportional to the number of different products and the number of customers.
-- Employees should be expected to work towards reaching new customers and increasing the product range.

-- EMPLOYEE SHIPMENT DURATIONS

select o.employee_id,title, sum(od.unit_price*od.quantity*(1-od.discount))::integer as total_sales,
count(distinct od.product_id) as unique_product_count,
count(distinct od.order_id) as order_count,
count(distinct o.customer_id) as customer_count,
round(avg(shipped_date-order_date), 1) as shipment_duration_days
from orders as o
left join order_details as od using(order_id)
left join employees as e using(employee_id)
where shipped_date is not null
group by 1,2
order by 7 desc

-- The number of products, number of orders or number of customers does not seem to directly affect the shipping time.
-- The long shipping time of the employee with ID_9 should be questioned

-- WHAT PRODUCTS DO EMPLOYEES SELL MOST AND HOW MUCH IS THE SALES REVENUE? (TOP 3 PRODUCTS BY REVENUE)

with first_3 as (
with quantities as (
select e.employee_id,
od.product_id,
sum(quantity) as sales_quantity,
SUM(unit_price*quantity*(1-discount) )::integer as sales_revenue
from employees as e
inner join orders as o using(employee_id)
inner join order_details as od using(order_id)
group by 1,2
order by 1,3 desc
)
select *,
rank() over(partition by employee_id order by sales_quantity desc) as quantity_order,
rank() over(partition by employee_id order by sales_revenue desc) as revenue_order
from quantities
order by 1
)
select * from first_3 where revenue_order <4
order by 1, 6

-- The remarkable result is that, in general, products with high sales returns are products with
-- high unit prices, not in quantity.

--  5 - SHIPPING COMPANIES ANALYSIS

--WHAT IS THE TOTAL TRANSPORTATION AMOUNT, TOTAL SALES REVENUE AND TRANSPORTATION-SALES REVENUE RATIO BY COMPANY?

select ship_via as "shipping company", sum(freight) "shipping cost",
sum(unit_price*quantity*(1-discount)) as "total revenue",
sum(freight)*100/ sum(unit_price*quantity*(1-discount)) as "shipping cost- sales revenue perc"
from orders 
left join order_details using(order_id) 
group by 1
order by 1

-- WHAT IS THE EFFECT OF SHIPMENT PLACE ON TRANSPORTATION AMOUNT/SALES REVENUE RATIO?

Select
ship_country as shipped_country,
ship_city as shipped_city,
sum(freight) as shipping_cost,
sum(unit_price*quantity*(1-discount)) as sales_revenue,
sum(freight)*100/sum(unit_price*quantity*(1-discount)) as "shipping cost- sales revenue perc"
from orders as o
left join order_details as od
using(order_id)
group by 1,2
order by 5 asc

-- The lowest rate of transportation to the total shopping amount was Walla Walla, USA, with 5.43%, 
-- while the highest rate was Boise, USA, with 25.42%. While Germany Münster was 5.48%, Germany Cologne was 21.39%.
-- Although it is not a very healthy evaluation since we cannot access the profit rates, 
-- the fact that 20-25% of the total sales revenue goes to transportation is a data that should be evaluated.
-- If the profit remains low in cities where the transportation expense/sales revenue ratio is high
-- (for example, over 17%, since the highest average is 17.2% in 2), the TRANSPORTER policy for these cities can be reviewed.

-- WHAT IS THE EFFECT OF COMPANIES ON THE TRANSPORTATION AMOUNT/SALES REVENUE RATIO FOR USA BOISE, WHICH HAS THE HIGHEST RATE?

select ship_via as "shipping company", avg(freight) as "avg. shipping cost",
avg(unit_price*quantity*(1-discount)) as "avg. sales revenue",
avg(freight)*100/ avg(unit_price*quantity*(1-discount)) as "shipping cost-sales revenue perc"
from orders 
left join order_details using(order_id) 
where ship_city = 'Boise' group by 1
order by 1
--
select ship_via as "shipping company", sum(freight) as "total shipping cost",
sum(unit_price*quantity*(1-discount)) "total sales revenue",
sum(freight)*100/ sum(unit_price*quantity*(1-discount))as "shipping cost-sales revenue perc"
from orders 
left join order_details using(order_id) 
where ship_city = 'Boise' group by 1
order by 1

-- Considering all the data, the ratios of companies that are close to each other can differ greatly in private.
-- The results clearly show the advantage of the transportation company with id_1. This requires reviewing 
-- the shipping policy, especially in places where the TRANSPORTATION AMOUNT/SALES REVENUE ratio is high.


-- 6 - SHIPMENT TIME ANALYSIS

-- WHAT IS THE EFFECT OF TRANSPORTATION COMPANIES AND SUPPLIERS ON THE SHIPMENT TIME?
--Transportation Companies

select ship_via as shipping_company,
round(avg(shipped_date-order_date),2) as avg_ship_duration
from orders
group by 1
order by 2

-- Suppliers
select 
s.supplier_id as supplier_id,
round(avg(shipped_date-order_date),2) as avg_ship_duration
from suppliers as s 
inner join products as p using(supplier_id)
inner join order_details as od using(product_id)  
inner join orders using(order_id)
group by 1
order by 2 desc

with ordered as (
select o.ship_via as shipping_company,
s.supplier_id as supplier_id,
round(avg(shipped_date-order_date),2) as avg_ship_duration,
dense_RANK() over(partition by o.ship_via order by avg(shipped_date-order_date) desc) as orderr
from orders as o
inner join order_details as od using(order_id)
inner join products as p using(product_id)
inner join suppliers as s using(supplier_id)
group by 1,2
order by 1, 3 desc
)
select * from ordered where orderr < 10

-- Shipping companies are ranked 3-1-2 from best to worst in terms of lead time
-- Suppliers are ranked from worst to best in terms of lead time as 23-18-4-20-12-11-15-26
-- The result of the transporter-supplier query also shows that 3 is the best transporter because it works
-- less with long-term suppliers; The worst outcome of the carrier with 2 id_s seems to be due to the fact that
-- it works with suppliers with long deadlines.

-- DO SUPPLIER'S COUNTRY AND CUSTOMER'S COUNTRY AFFECT THE SHIPMENT TIME?

select sup.country as supplier_country,
round(avg(o.shipped_date - o.order_date),1) as avr_ship_duration
from orders as o
inner join order_details as od using(order_id)
inner join products as p using(product_id)
inner join suppliers as sup using(supplier_id)
group by 1
order by 2 desc

select ship_country as customer_country,
round(avg(shipped_date - order_date),1) as avr_ship_duration
from orders
group by 1
order by 2 desc


select sup.country as supplier_country,
o.ship_country as customer_country,
round(avg(o.shipped_date - o.order_date),1) as avr_ship_duration
from orders as o
inner join order_details as od using(order_id)
inner join products as p using(product_id)
inner join suppliers as sup using(supplier_id)
group by 1,2
order by 1,3
-- We can say that the distance between the supplier's country and the country 
-- where the order will be sent does not affect the delivery time.
-- these results can be used for further analysis such as Australia Denmark average delivery time is 4.7 days,
-- while Australia Italy average delivery time is 14.6 days. A research on Italy can be done here.

--WHAT IS THE ORDER DISTRIBUTION OF THE TRANSPORTATION COMPANY IN CUSTOMER COUNTRIES WITH LONG AVERAGE DELIVERY TIMES?

select ship_via as shipping_company,
count(*) as order_count
from orders 
where ship_country in ('Ireland', 'Switzerland', 'USA' ,'Argentina', 'Sweden', 'Belgium', 'Spain')
group by 1
order by 2 desc
-- The shipping company with 2 ID_s showed the longest delivery times, and the fact that the number of orders 
-- is high here suggests that the shipping company has a share.

-- -- What is the distribution of orders going from supplier countries with long delivery times to 
-- delivery countries with long delivery times, according to shipping companies?

select ship_via as shipping_company,
count(distinct od.order_id) as order_count 
from suppliers as s
inner join products as p using(supplier_id)
inner join order_details as od using(product_id)
inner join orders as o using(order_id)
where ship_country in ('Ireland', 'Switzerland', 'USA' ,'Argentina', 'Sweden', 'Belgium', 'Spain')
and s.country in ('Singapore', 'Finland', 'USA' ,'Japan', 'Germany', 'Norway', 'Spain')
group by 1 
order by 2 desc
-- 

-- WHAT IS THE DISTRIBUTION OF TRANSPORTATION COMPANIES IN SUPPLIER COUNTRIES WITH LONG AVERAGE DELIVERY TIMES?

select ship_via as shipping_country,
count(*) as order_count
from orders as o
inner join order_details as od using (order_id)
inner join products as p using(product_id)
inner join suppliers as s using(supplier_id)
where s.country in ('Singapore', 'Finland', 'USA' ,'Japan', 'Germany', 'Norway', 'Spain')
group by 1
order by 2 desc
-- The shipping company with 2 ID_s showed the longest delivery times, and the fact that the number of orders
-- is high here suggests that the shipping company has a share.

--WHAT IS THE EFFECT OF PRODUCTS ON THE SHIPPING TIME?

select product_id,
round(avg(o.shipped_date - o.order_date),1) as avr_ship_duration
from orders as o
inner join order_details as od using(order_id)
group by 1 
order by 2 desc

-- WHAT IS THE EFFECT OF PRODUCTS AND SHIPPERS ON SHIPPING TIME?

select product_id,
ship_via as shipping_company,
round(avg(o.shipped_date - o.order_date),1) as avr_ship_duration
from orders as o
inner join order_details as od using(order_id)
group by 1 , 2
order by 3 desc

-- When we evaluate both queries together, it can be seen that carrier number 2 really seems to have an effect
-- on the length of delivery times. However, we can say that mainly long delivery times are related to 
-- the products themselves.


-- 7 - PRODUCT CATEGORY ANALYSIS

-- HOW MUCH IS THE SHIPPING TIME, TOTAL ORDER AMOUNT, NUMBER OF ORDERS AND SHIPPING COSTS ACCORDING TO THE CATEGORY OF THE PRODUCT?

SELECT category_name,
c.category_id,
sum(od.unit_price*od.quantity*(1-od.discount))::integer as total_order_amount,
sum(quantity) as product_count,
(sum(od.unit_price*od.quantity*(1-od.discount))/sum(quantity))::integer as avr_product_price,
SUM(freight)::integer as shipping_cost,
count(distinct order_id) as order_count,
(sum(freight)/count(distinct order_id)):: integer as shipping_cost_per_order,
round(avg(shipped_date-order_date),2) as avr_ship_duration
from categories as c
inner join products using(category_id)
inner join order_details AS od using(product_id)
inner join orders using(order_id)
group by 1,2
order by 3 desc

-- TRANSPORTATION COMPANIES AND SUPPLIERS OF THE CONDIMENTS CATEGORY PRODUCTS WITH THE HIGHEST AVERAGE DELIVERY TIME

SELECT category_name,
c.category_id,
supplier_id as supplier_id, 
ship_via as shipping_company,
round(avg(shipped_date-order_date),2) as avr_ship_duration
from categories as c
inner join products as p using(category_id)
inner join order_details as od using(product_id)
inner join orders as o using(order_id)
where category_id=2
group by 1,2 ,3,4
order by 5 desc
-- Shipping companies are ranked 2-1-3 from worst to best in terms of lead time
-- Suppliers are ranked from worst to best in terms of lead time as 23-18-4-20-12-11-15-26
-- 2 of 8 bad suppliers (20 and 12) are on the list, while the worst shipping company is 2.1/2
-- Long shipping times for YaniCondimets category products seem to be caused by the carrier rather than the supplier.
-- We should not ignore the possibility of a natural delay due to the category itself.

-- DOES CATEGORY HAVE AN EFFECT ON EMPLOYEES' DELIVERY TIMES?
-- THE LONGEST ORDER TIME WAS WITH EMPLOYEE ID:9 AND THE SHORTEST ORDER TIME WAS WITH EMPLOYEE ID:5.

SELECT employee_id,
category_name as product_category,
round(avg(shipped_date-order_date),2) as avr_ship_duration
from orders as o 
inner join order_details as od using(order_id)
inner join products as p using(product_id)
inner join categories using (category_id)
where employee_id in (5,9)
group by 1 ,2
order by 3 desc
-- Length of delivery times appear to be affected by supplier rather than product category

-- SHIPMENT TIMES BY EMPLOYEES AND SUPPLIERS IN THE CATEGORIES WITH THE 2 LONGEST SHIPMENT TIMES

SELECT employee_id,
category_id,
supplier_id,
round(avg(shipped_date-order_date),2) as avr_ship_duration
from orders as o 
inner join order_details as od using(order_id)
inner join products as p using(product_id)
where employee_id in (4,9)  
group by 1 ,2,3
having category_id in (2,3)
order by 4 desc

-- From this query we can say that suppliers are not very effective in long delivery times
