select * from df_orders;





--find top 10 highest revenue generating products
select top 10 product_id,sum(sale_price) as revenue from df_orders
group by product_id
order by revenue desc;


--find top 5 highest selling products in each region
with cte as(
select region,product_id,sum(sale_price) as sales
from df_orders
group by region,product_id
)
select * from (
select *
, row_number() over(partition by region order by sales desc) as rn
from cte) A
where rn<=5;


--find month over month growth comparision for 2022 and 2023:- jan 2002 and jan 2023
with cte as (
select year(order_date) as order_year,month(order_date) as order_month,
sum(sale_price) as sales
from df_orders
group by year(order_date),month(order_date)
)
select order_month
,sum(case when order_year=2022 then sales else 0 end) as sales_2022
,sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte
group by order_month
order by order_month;

--for each ctaegory which month had highest sales.
with cte as (
select category,year(order_date) as order_year, month(order_date) as order_month,sum(sale_price) as sales 
from ananthdb1.dbo.df_orders
group by category,year(order_date),month(order_date)
)

select * from
(select *
,rank() over(partition by category order by sales desc) as rn
from cte) A
where rn=1;


--which sub-category had the highest growth by profit in 2023 comparing to 2022

with cte as ( 
select sub_category,year(order_date) as order_year,round(sum(profit),2) as profit_cat
from ananthdb1.dbo.df_orders
group by sub_category,year(order_date)
)
, cte2 as (
 select sub_category
,sum(case when order_year=2022 then profit_cat else 0 end) as profit_2022
,sum (case when order_year=2023 then profit_cat else 0 end) as profit_2023
from cte
group by sub_category)

select top 1 * , (profit_2023-profit_2022)*100/profit_2022 as growth
from cte2
order by growth desc;