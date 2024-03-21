select * from Customer
select * from prod_cat_info
select * from Transactions


create database reatail_data_analysis;
--1)

select COUNT(*) as table_count from customer
union
select COUNT(*) as table_count from prod_cat_info
union
select COUNT(*) as table_count from transactions

--2)

select count(distinct(transaction_id)) as final_trans from Transactions
where Qty < 0

--3)

select CONVERT(date,tran_date,105) as trctn_date from Transactions

--4)

select DATEDIFF(year,MIN(CONVERT(date,tran_date,105)),MAX(CONVERT(date,tran_date,105))) as df_yrs,
DATEDIFF(MONTH,MIN(CONVERT(date,tran_date,105)),MAX(CONVERT(date,tran_date,105))) as df_mnths,
DATEDIFF(DAY,MIN(CONVERT(date,tran_date,105)),MAX(CONVERT(date,tran_date,105))) as df_days
from transactions

--5)

select prod_cat,prod_subcat from prod_cat_info
where prod_subcat='DIY'


--DATA ANALYSIS

--1)

 select top 1 store_type,count(*) as cnt from Transactions
 group by Store_type
 order by cnt desc

 --2)

 select gender,count(*) as cnt from Customer
 where Gender is not null
 group by Gender

 --3)

 select top 1 city_code,count(*) as cnt from Customer
 group by city_code
 order by cnt desc

 --4)

 select prod_cat,prod_subcat from prod_cat_info
 where prod_cat='books'

 --5)

 select prod_cat_code,MAX(Qty) AS max_prdct from Transactions
 group by prod_cat_code

 --6)

 select sum(cast (total_amt as float)) as net_revenue from prod_cat_info as p1
 join Transactions as T
 on p1.prod_cat_code = T.prod_cat_code and p1.prod_sub_cat_code = T.prod_subcat_code
 where prod_cat = 'books' or prod_cat = 'Electronics'

 --7)
  select count(*) as total_cust from (
  select cust_id ,count(distinct(transaction_id)) as count_trstcn from Transactions
  where Qty > 0
  group by cust_id
  having count(distinct(transaction_id)) >10
  ) as t5

  --8)

  select sum(cast(total_amt as float)) as combined_revenues from prod_cat_info as p
  join Transactions  as t
  on p.prod_cat_code = t.prod_cat_code and p.prod_sub_cat_code = t.prod_subcat_code
  where prod_cat in ('clothing','electronics') and Store_type = 'flagship store' and Qty > 0

  --9)

  select prod_subcat,sum(cast(total_amt as float)) as total_revenue from Customer as TR
  join Transactions as T
  on Tr.customer_Id = T.cust_id
  join prod_cat_info as t3
  on T.prod_cat_code = t3.prod_cat_code and t.prod_subcat_code = t3.prod_sub_cat_code
  where Gender = 'M' and prod_cat = 'electronics'
  group by prod_subcat

  --10)

---percentage of sales
select t5.prod_subcat,percentage_sales,percentage_returns from(
Select top 5 prod_subcat, (sum(cast(total_amt as float))/(Select sum(cast(total_amt as float)) as total_sales from Transactions where Qty > 0)) as percentage_sales
from prod_cat_info as p
join Transactions as t
on p.prod_cat_code = t.prod_cat_code AND p.prod_sub_cat_code =t.prod_subcat_code
where qty > 0 
group by prod_subcat
order by percentage_sales desc
) as t5
join
--percentage of returns
(
Select prod_subcat, (sum(cast (total_amt as float))/(Select sum(cast (total_amt as float)) as total_sales from Transactions where qty <0)) as percentage_returns
from prod_cat_info as p
Join Transactions as t
on p.prod_cat_code = t.prod_cat_code AND p.prod_sub_cat_code = t.prod_subcat_code
where Qty < 0
group by prod_subcat )t6
on t5.prod_subcat=t6.prod_subcat

--11)
 
--age of customer

select * from (
Select * from (
Select cust_id, DATEDIFF(year,dob,maximum_date) as age, revenues from (
Select cust_id, dob, max (convert (date, tran_date, 105)) as maximum_date ,sum(cast (total_amt as float)) as revenues from Customer as c
join Transactions as t
on c.customer_Id = t.cust_id
where qty > 0 
group by cust_id, DOB 
 )as A
		  ) as B
where Age between 25 and 35
                              ) as c

join (
-- last 30 days of transactions.
Select cust_id, convert(date, tran_date,105) as transaction_date 
from Transactions
group by cust_id, convert(date, tran_date,105)
having CONVERT(date,tran_date,105) >=( Select dateadd(day, -30,max(convert (date, tran_date,105))) as cuttoffs_date from Transactions)
 ) as D
 on c.cust_id = d.cust_id

 --12)

 select top 1 prod_cat_code, sum(returns) as total_returns from (

 Select prod_cat_code, convert(date, tran_date,105) as transaction_date, sum(qty) as returns
from Transactions
where qty < 0 
group by prod_cat_code, convert(date, tran_date,105)
having CONVERT(date,tran_date,105) >=( Select dateadd(month, -3,max(convert (date, tran_date,105))) as cuttoffs_date from Transactions)
 ) as a
 group by prod_cat_code
 order by total_returns


 --13)

 select store_type, sum(cast(total_amt as float)) as revenues, sum(qty) as quantity
 from Transactions
 where qty > 0
 group by Store_type
 order by revenues desc,Quantity desc

 --14)

 select prod_cat_code, AVG(cast(total_amt as float)) as average_revenues from Transactions
 where Qty > 0
 group by prod_cat_code
 having  AVG(cast(total_amt as float)) >= (select AVG(cast(total_amt as float)) from Transactions where Qty > 0)

 --15)

 select prod_subcat_code, sum(cast(total_amt as float)) as revenues , AVG(cast(total_amt as float)) as average_revenues
 from Transactions
 where Qty > 0 and prod_cat_code  in (select top 5 prod_cat_code from Transactions
                                         where Qty > 0
                                         group by prod_cat_code
                                         order by sum(Qty) desc  )

 group by prod_subcat_code




 

