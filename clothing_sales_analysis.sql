create database clothing_sales;
use clothing_sales;
-- 1.Total revenue --
select sum(totalAmount) as total_sales 
from sales_data_updated;

-- 2.Total profit --
select sum(totalAmount-totalcost) as total_profit 
from sales_data_updated;

-- 3.Most profitable product --
select productName,
round(sum(totalAmount-totalcost),2) as profit
from sales_data_updated
group by productName
order by profit desc limit 5;

-- 4.Best category in each location --
select location,
productCategory,
round(sum(totalAmount),2)as sales
from sales_data_updated
group by location,productCategory
order by sales desc;

-- 5.Category with sales greater than 3500000 --
select productCategory,
round(sum(totalAmount),2)as sales
from sales_data_updated
group by productCategory
having sum(totalAmount)>3500000
order by sales desc;

-- 6.top 5 product category by profit --
select productCategory,
round(sum(profit),2) as sales_profit
from sales_data_updated
group by productCategory
order by sales_profit desc limit 5;

-- 7. Customers Who Spent More Than 5,000 --
select customerName,
sum(totalAmount) AS total_spent
from sales_data_updated
group by customerName
having sum(totalAmount) > 5000
order by total_spent desc;

-- 8. Locations with More Than 1200 Sales --

select location,
count(*) as sales_count
from sales_data_updated
group by location
having count(*) > 1200;

-- 9. Top 3 Customers by Spending --
select *
from (
    select customerName,
           sum(totalAmount) as total_spent,
           rank() over(
			order by sum(totalAmount) desc
           ) as customer_rank
   from sales_data_updated
    group by customerName
) t
where customer_rank <= 3;

-- 10. Rank Products Within Each Category --

select productCategory,
       productName,
       sum(totalAmount)as sales,
      rank()over (
           partition by productCategory
           order by sum(totalAmount) desc
       ) as rank_in_category
from sales_data_updated
group by productCategory, productName;

-- 11. Most Profitable Product in Each Category --
select *
from (
    select productCategory,
           productName,
		   sum(totalAmount - totalCost) as profit,
           row_number() over (
               partition by productCategory
               order by SUM(totalAmount - totalCost) desc
           ) as rn
   from sales_data_updated
    group by productCategory, productName
) t
where rn = 1;
-- 12. Rank Locations by Revenue --

select location,
       round(sum(totalAmount),2) as revenue,
       dense_rank() over (
           order by sum(totalAmount) desc
       ) as location_rank
from sales_data_updated
group by location;

-- 13.Top two products in each category --

select*
from (
select productCategory,
       productName,
       round(sum(totalAmount),2) as sales,
       row_number() over(partition by productCategory
       order by sum(totalAmount) desc
       ) as product_rank from sales_data_updated
       group by productCategory,
       productName
) t
where product_rank<=2;

-- 14. pivoting with  conditional aggregation --

select productCategory,
	round(sum(case when salesChannel='Online' then totalAmount else 0 end),2)
    as online_sales,
    
    round(sum(case when salesChannel='in-store' then totalAmount else 0 end),2)
    as store_sales,
    
    round(sum(case when salesChannel='mobile_app' then totalAmount else 0 end),2)
    as mobile_app_sales
    from sales_data_updated
    group by productCategory
    order by online_sales,store_sales, mobile_app_sales desc;

-- 15.Total sales using with clause
 WITH category_sales AS (
    SELECT productCategory,
           SUM(totalAmount) AS total_sales
    FROM sales_data_updated
    GROUP BY productCategory
)
SELECT *
FROM category_sales;

-- 16.quantity category --

select saleID,
       quantity,
       case
           when quantity>=10 then 'Bulk order'
      else 'regular order' end as order_type
      from sales_data_updated;

-- 17. Total sales of weekdays and weekenda --
select
    case
       when DAYOFWEEK(saleDate) in (1, 7) then'Weekend'
        else 'Weekday'
end as day_type,
   round(sum(totalAmount),2) as total_sales
from sales_data_updated
group by day_type;

 -- 18.Total sales for every year --
 
 select year(saleDate) as year,
        round(sum(totalAmount),2) as total_sales
        from sales_data_updated
        group by year(saleDate)
        order by year(saleDate);
        