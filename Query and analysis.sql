
-- To start with for ease in calculation we will calculate add cost(aty*price) & bill_amt(cost-discount) column in table itself

alter table product_sales
add  cost int
alter table product_sales
add bill_amt float

update product_sales
set cost = qty*price
where 1=1
update product_sales
set bill_amt = cost*(1-discount*0.01)
where 1=1

-------------------- Set1 --------------------

--What was the total quantity sold for all products?
select pd.product_name, SUM(qty) as total_quantity_sold
from product_sales ps join product_details pd
on ps.prod_id = pd.product_id
group by pd.product_name

--What is the total generated revenue for all products before discounts?
select sum(cost) as total_revenue_b4_discount
from product_sales ps

--What was the total discount amount for all products?
select sum(discount*0.01*price) as total_discount
from product_sales

-------------------- Set2 --------------------

--How many unique transactions were there?
select COUNT(distinct txn_id) as unique_transactions
from product_sales

--What is the average unique products purchased in each transaction?
select txn_id,COUNT(distinct prod_id) as No_of_unique_products
from product_sales
group by txn_id

--What are the 25th, 50th and 75th percentile values for the revenue per transaction?
select top 1 PERCENTILE_CONT(0.25) within group (order by bill_amt desc) over() as ptile_25
,PERCENTILE_CONT(0.50) within group (order by bill_amt desc) over() as ptile_50
,PERCENTILE_CONT(0.75) within group (order by bill_amt desc) over() as ptile_75
from product_sales

--What is the average discount value per transaction?
select txn_id, AVG(discount*0.01*price) as avg_discount_per_transaction
from product_sales
group by txn_id

--What is the percentage split of all transactions for members vs non-members?
select sum(case when member = 'true' then 1 else 0 end)*100.00/COUNT(1) as pct_member 
, 100 - sum(case when member = 'true' then 1 else 0 end)*100.00/COUNT(1) as pct_nonmember
from product_sales

--What is the average revenue for member transactions and non-member transactions?
select sum(case when member = 'true' then bill_amt else 0 end)/sum(case when member = 'true' then 1 else 0 end) as pct_member 
, sum(case when member = 'false' then bill_amt else 0 end)/sum(case when member = 'false' then 1 else 0 end) as pct_nonmember
from product_sales

-------------------- Set3 --------------------

--What are the top 3 products by total revenue before discount?
select top 3 pd.product_name, SUM(cost) as rev_before_discount
from product_sales ps join product_details pd
on ps.prod_id=pd.product_id
group by pd.product_name
order by SUM(cost) desc

--What is the total quantity, revenue and discount for each segment?
select segment_name,sum(qty) as total_quantity, SUM(bill_amt) total_revenue, SUM(discount) as total_discount
from product_details pd join product_sales ps
on ps.prod_id = pd.product_id
group by segment_name ;

--What is the top selling product for each segment?
--interms of value
with cte1 as ( select segment_name,product_name, SUM(bill_amt) revenue , 
 RANK() over(partition by segment_name order by SUM(bill_amt) desc) as rn
from product_sales ps join product_details pd
on ps.prod_id=pd.product_id
group by segment_name,product_name )
select segment_name, product_name,revenue
from cte1 
where rn=1;

--in terms of volume
with cte1 as ( select segment_name,product_name, sum(qty) as quantity , 
 RANK() over(partition by segment_name order by SUM(qty) desc) as rn
from product_sales ps join product_details pd
on ps.prod_id=pd.product_id
group by segment_name,product_name )
select segment_name, product_name,quantity
from cte1 
where rn=1

--What is the total quantity, revenue and discount for each category?
select category_name,sum(qty) as total_quantity, SUM(bill_amt) total_revenue, SUM(discount) as total_discount
from product_details pd join product_sales ps
on ps.prod_id = pd.product_id
group by category_name ;

--What is the top selling product for each category?
--interms of value
with cte1 as ( select category_name,product_name, SUM(bill_amt) revenue , 
 RANK() over(partition by category_name order by SUM(bill_amt) desc) as rn
from product_sales ps join product_details pd
on ps.prod_id=pd.product_id
group by category_name,product_name )
select category_name, product_name,revenue
from cte1 
where rn=1;

--in terms of volume
with cte1 as ( select category_name,product_name, sum(qty) as quantity , 
 RANK() over(partition by category_name order by SUM(qty) desc) as rn
from product_sales ps join product_details pd
on ps.prod_id=pd.product_id
group by category_name,product_name )
select category_name, product_name,quantity
from cte1 
where rn=1

--What is the percentage split of revenue by product for each segment?
select segment_name,product_name, SUM(bill_amt)*100.00/
 sum(SUM(bill_amt)) over(partition by segment_name order by segment_name) as pct_share_in_revenue
from product_sales ps join product_details pd
on ps.prod_id=pd.product_id
group by segment_name,product_name

--What is the percentage split of revenue by segment for each category?
select category_name,segment_name, SUM(bill_amt)*100.00/
 sum(SUM(bill_amt)) over(partition by category_name order by category_name) as pct_share_in_revenue
from product_sales ps join product_details pd
on ps.prod_id=pd.product_id
group by category_name,segment_name

--What is the percentage split of total revenue by category?
select category_name, SUM(bill_amt)*100.00/
sum(SUM(bill_amt)) over() as pct_share_in_revenue
from product_sales ps join product_details pd
on ps.prod_id=pd.product_id
group by category_name ;

--What is the total transaction penetration for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)
with cte1 as (
select pd.product_name,COUNT(1) as penetration
from product_sales ps join product_details pd
on ps.prod_id=pd.product_id
group by pd.product_name )
,cte2 as (select count(distinct txn_id) as total_transaction
from product_sales)
select product_name,penetration*100.00/ total_transaction as pct_penetration
from cte1,cte2 ;

--What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?
with cte as (
select a.prod_id a,b.prod_id b,c.prod_id c, COUNT(*) countForCombination , dense_rank()over(order by COUNT(*) desc) as rn
from product_sales a join product_sales b
on a.txn_id=b.txn_id and a.prod_id < b.prod_id
join product_sales c
on a.txn_id=c.txn_id and a.prod_id>c.prod_id 
group by a.prod_id,b.prod_id,c.prod_id )
select a,b,c, countForCombination from cte where rn=1 ;


----------------- Advance_level -----------------

--Use a single SQL query to transform the product_hierarchy and product_prices datasets to the product_details table.


with cte1 as (
select id,parent_id, case when level_name = 'category' then level_text else null end AS Category 
,case when level_name = 'Segment' then level_text else null end as Segment
,case when level_name = 'Style' then level_text else null end as Style
from product_hierarchy )
, cte2 as (
select c1.Category,c2.Segment,c2.id,c2.parent_id,c2.Style
from cte1 c1 join cte1 c2 on c1.id=c2.parent_id )
,cte3 as (
select c1.Category,c1.Segment,c2.Style,c1.parent_id as Category_id,c1.id as Segment_id, c2.id as Style_id
from cte2 c1 join cte2 c2 on c1.id=c2.parent_id )
select product_id,price,CONCAT(Style,' ',Segment,' - ',Category) product_name
,Category_id,Segment_id,Style_id,Category Category_name,Segment Segment_name, Style Style_name
from cte3 join product_prices on product_prices.id=cte3.Style_id
