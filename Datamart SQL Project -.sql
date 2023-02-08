use case1;
select * from weekly_sales limit 17000;
#DATA Cleaning -------------------------------------------------------------------------------------------------------------------------------
Create table clear_weekly_sales as select week_date, week(week_date) as week_number,month(week_date) as month_number,year(week_date) as calender_year,region,platform,
case
when segment = null then 'Unknown'
else segment
end as segment,
case
when right(segment,1) = '1' then 'Young Adult'
when right(segment,1) = '1' then 'Middle Aged'
when right(segment,1) in ('3','4') then 'Retirees'
else 'Unknown'
end as age_band,

case
when left(segment,1) = 'C' then 'Couples'
when left(segment,1) = 'F' then 'Families'
else 'Unknown'
end as demographic,transactions,sales, round(sales/transactions,2) as 'Avg_transaction' from weekly_sales;

select * from clear_weekly_sales LIMIT 20;

## Data Exploration---------------------------------------------------------------------------------------------------------------------------
## 1.Which week numbers are missing from the dataset?

create table seq100( x int auto_increment primary key);
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 select x+50 from seq100;
select * from seq100;

create table seq52 as (select x from seq100 Limit 52);
select distinct x as week_day from seq52 
where x not in (select distinct week_number from clear_weekly_sales);

## 2.How many total transactions were there for each year in the dataset?

select calender_year, sum(transactions) as sum_of_transactions from clear_weekly_sales group by calender_year;

## 3.What are the total sales for each region for each month?
select month_number,region,sum(sales) from clear_weekly_sales group by month_number,region;


## 4.What is the total count of transactions for each platform
select platform, sum(transactions) as total_count_of_transactions from clear_weekly_sales group by platform;


## 5.What is the percentage of sales for Retail vs Shopify for each month?

with cte_monthly_platform_sales as (select month_number,calender_year,platform,sum(sales) as monthly_sales from clear_weekly_sales group by month_number,calender_year,platform)
  
  select month_number,calender_year, round(100*max(case when platform = 'Retail' then monthly_sales else null end)/sum(monthly_sales),2) as retail_percrentage,
  round(100*max(case when platform = 'Shopify' then monthly_sales else null end)/sum(monthly_sales),2) as shopify_percrentage from cte_monthly_platform_sales group by month_number, calender_year order by month_number, calender_year;
  
  ## 6.What is the percentage of sales by demographic for each year in the dataset?

select calender_year,demographic,sum(sales) as yearly_sales, round((100*sum(sales)/sum(sum(sales)) over (partition by demographic)),2) as percentage from clear_weekly_sales GROUP BY calender_year,demographic ORDER BY calender_year, demographic;


  ## 7.Which age_band and demographic values contribute the most to Retail sales?
  
  select age_band,demographic,sum(sales) as total_sales from clear_weekly_sales where platform = 'Retail' group by age_band,demographic order by total_sales desc;
  