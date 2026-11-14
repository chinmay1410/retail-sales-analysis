-- create database retail_db;
select count(*)  from orders;

-- Q1. How is the business doing overall?
select cast(sum(sales) as decimal (12,2)) as total_sales,
cast(sum(profit) as decimal(12,2)) as total_profit,
count(distinct order_id) as total_orders,
cast(sum(profit) / sum(sales) * 100 as decimal(6,2)) as profit_margin_pct
from orders;

-- Q2. Which category earns the most profit and at what margin?
select category,
cast(sum(sales) as decimal(12,2)) as total_sales,
cast(sum(profit) as decimal(12,2)) as total_profit,
cast(sum(profit) / sum(sales) * 100 as decimal(6,2)) as margin_pct
from orders group by category order by total_profit desc;

-- Q3. Top 10 products by profit.
select product_name,
cast(sum(profit) as decimal(12,2)) as total_profit
from orders group by product_name order by total_profit desc
limit 10;

-- Q4. 10-most loss making products.
select product_name,
cast(sum(profit) as decimal(12,2)) as total_profit
from orders group by product_name order by total_profit asc
limit 10;

-- Q5. Which region is least profitable?
select region,
cast(sum(sales) as decimal(12,2)) as total_sales,
cast(sum(profit) as decimal(12,2)) as total_profit,
cast(sum(profit) / sum(sales) * 100 as decimal(6,2)) as margin_pct
from orders group by region order by total_profit desc;

-- Q6. Monthly sales trend.
select date_format(order_date, '%Y-%m') as month,
cast(sum(sales)as decimal(12,2)) as total_sales
from orders 
group by date_format(order_date, '%Y-%m')
order by month;

-- Q7. Does a higher discount reduce profit?
select case when discount = 0  then '1. No discount'
when discount <=0.2 then '2. upto 20%.'
when discount <= 0.4 then '3. 21 to 40%.'
else '4. over 40%.' end as discount_band,
count(*) as order_lines,
cast(sum(profit) as decimal(12,2)) as total_profit,
cast(avg(profit) as decimal(12,2)) as avg_profit_per_line
from orders group by discount_band order by discount_band;

-- Q8. Top 10 customer by sales.
select customer_id, customer_name,
count(distinct order_id) as orders,
cast(sum(sales) as decimal(12,2)) as total_sales
from orders group by customer_id, customer_name
order by total_sales desc limit 10;

-- Q9. Rank sub-categories by profit inside each category.
select category, sub_category,
cast(sum(profit) as decimal(12,2)) as total_profit,
rank() over(partition by category order by sum(profit) desc) as rank_in_category
from orders group by category, sub_category order by category,rank_in_category;

-- Q10. Year-Over-Year sales growth.
with yearly as(
select extract(year from order_date) as Yr,
sum(sales) as total_sales 
from orders group by extract(year from order_date))
select Yr,
cast(total_sales as decimal(12,2)) as total_sales,
cast((total_sales - lag(total_sales) over (order by Yr)) 
/ lag(total_sales) over (order by Yr) * 100  as decimal(6,2)) as YOY_growth_pct
from yearly;