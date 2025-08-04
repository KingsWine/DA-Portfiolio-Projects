select * from adidas;

-- Basic Data cleaning
alter table adidas								-- to add a new date column
add column new_invoice_date date;

update adidas									-- to populate the date column
set new_invoice_date = date_format(STR_TO_DATE(invoice_date, '%m/%d/%Y'), '%m-%d-%Y');


-- select all columns and records where region is 'Northeast
select * from adidas where region = 'Northeast';

-- select retailer, city, product, unitsold and totalsales
select retalier, city, product, unit_sold sales from adidas;

-- retrieve all records where units sold is greater than 1000, ordered by units sold descending
select * from adidas where unit_sold > 1000 order by unit_sold desc;

-- find all sales records in 'New york' with sales between 300000 and 600000
select * from adidas where city = 'New York' and sales between 300000 and 600000;

-- list unique product types sold by 'foot locker'
select distinct(product) from adidas where retailer = 'Foot Locker';


-- find the total units sold per product
select product, sum(unit_sold) total_units from adidas group by product;

-- find the total and average operating profit per retailer
select retailer, sum(operating_profit) sum_op_profit, avg(operating_profit) avg_op_profit
from adidas
group by retailer;

-- for each state, compute the sum of the total sales and average unit sold
select state, sum(sales) total_sales, avg(unit_sold) avg_unit_sold
from adidas
GROUP BY state;

-- count how many transactions were made per sales method
select sales_method, count(*)
from adidas
group by sales_method;

-- list the product with the highest total units sold
select product, sum(unit_sold)
from adidas
group by product
order by sum(unit_sold) desc
limit 1;

/* Create a derived column showing Price per Unit multiplied by Units Sold
and compare it with Total Sales for consistency checks. */
SELECT unit_price, unit_sold, sales, unit_price * unit_sold as sales_derived
from adidas;

-- Concatenate State and City into a single column as Location
select state, city, concat(state, ' ', city) address
from adidas;

-- Extract the year from Invoice Date.
SELECT invoice_date, year(invoice_date)
from adidas;

-- Check if Sales Method contains the string 'store' using LIKE.
select sales_method
from adidas
having sales_method like '%store';

-- Compute the running total of Units Sold ordered by Invoice Date.
select invoice_date, unit_sold, sum(unit_sold) over (order by invoice_Date) as running_total
from adidas;

-- Show each sale with its Units Sold and the average Units Sold across all sales.
select sales, unit_sold, avg(unit_sold) over ()
from adidas;

-- Rank products sold based on Total Sales within each State.
select product, state, sales, rank() over (PARTITION BY state order by sales desc)
from adidas;

-- Compute the difference in Total Sales between the current and previous row ordered by Invoice Date.
select invoice_date,
	lag(sales, 1, 0) over (order by invoice_date) as prev_sales,
    lead(sales, 1, 0) over (order by invoice_date) as cur_sales,
    lead(sales, 1, 0) over (order by invoice_date) - lag(sales, 1, 0) over (order by invoice_date) as diffrence
from adidas;

-- Show the cumulative percentage of Total Sales using CUME_DIST().
select sales, CUME_DIST() over (order by sales desc)
from adidas;

-- Find products whose average Price per Unit is greater than the overall average Price per Unit.
select product, avg(unit_price) as product_avg
from adidas
GROUP BY product
having product_avg > (select avg(unit_price) from adidas);

-- List transactions where Total Sales is greater than the average Total Sales in "New York".
SELECT *
from adidas
where sales > (
	select avg(sales)
	from adidas
	where state = 'New York');

-- Select Retailer and Product with the highest Operating Profit.
SELECT retailer, product, operating_profit
FROM adidas
WHERE operating_profit >= (
    SELECT MAX(operating_profit) FROM adidas
);

-- Find cities with total Units Sold above the average units sold across all cities.
SELECT city, sum(unit_sold) as total_unit_sold
FROM adidas
GROUP BY city
having total_unit_sold > (
    SELECT avg(unit_sold) FROM adidas
);

-- Retrieve all transactions with Invoice Date on the same day as the maximum Total Sales date.
select *
from adidas
where invoice_date in (
	select invoice_date
    from adidas
    where sales = (
		select max(sales)
        from adidas)
	);

-- Create a CTE to calculate the total sales per product, then select products with total sales above 1 million.
with sales_product as (
	select product, Sum(sales) total_sales
    from adidas
    group by product
    )
select * from sales_product where total_sales > 1000000;

-- Use a CTE to get the average Operating Margin by Retailer and list retailers with averages above 40.
with retailer_margin as (
	select retailer, avg(operating_margin) avg_margin
    from adidas
    group by retailer
    )
select * from retailer_margin where avg_margin > 40;

-- Create a CTE that lists sales in 2020, then from it, find the top 5 transactions with the highest Total Sales.
with sales_2020 as (
	select *, year(invoice_date) as invoice_year
    from adidas
    where year(invoice_date) = 2020
    )
select * from sales_2020 ORDER BY sales desc limit 5;

-- Create a CTE that flags transactions as 'High' or 'Low' based on Units Sold > 1000.
WITH FlaggedTransactions AS (
    SELECT *,
        CASE 
            WHEN unit_sold > 1000 THEN 'High'
            ELSE 'Low'
        END AS SalesFlag
    FROM adidas
)
SELECT *
FROM FlaggedTransactions;

-- Create a view showing the monthly average Total Sales.
CREATE VIEW monthly_avg as
select month(invoice_date), avg(sales)
from adidas
group by month(invoice_date);

-- Create a view that displays Retailer, Product, Units Sold, and Operating Profit for "Foot Locker".
create view Foot_locker as
select retailer, product, unit_sold, operating_profit
from adidas
where retailer = 'Foot Locker';

-- Create a view showing Retailer, State, and their total Operating Profit.
CREATE view	State_profit as
select retailer, state, sum(operating_profit)
from adidas
GROUP BY state, retailer;

-- Create a temporary table containing all transactions in "Northeast".
CREATE TEMPORARY TABLE northeast_data as (
	select *
	from adidas
	where region = 'northeast');

-- Insert into a temporary table the top 10 transactions by Total Sales.
CREATE TEMPORARY TABLE top_10 as (
	select * from adidas order by sales desc limit 10 );

-- Use a temporary table to store Product and their average Units Sold for analysis.
create TEMPORARY TABLE temp_unit_sold as (
	select product, avg(unit_sold)
    from adidas
    GROUP BY product);

-- Create an index on Invoice Date for faster date filtering.
create INDEX ind_invoice_date on adidas (invoice_date);

-- Create a composite index on Region and State for optimized filtering.
create INDEX ind_composite on adidas( region, state);




