drop table if exists product_hierarchy
CREATE TABLE product_hierarchy (
  "id" INTEGER,
  "parent_id" INTEGER,
  "level_text" VARCHAR(19),
  "level_name" VARCHAR(8)
);

INSERT INTO product_hierarchy
  ("id", "parent_id", "level_text", "level_name")
VALUES
  ('1', NULL, 'Women', 'Category'),
  ('2', NULL, 'Men', 'Category'),
  ('3', '1', 'Jeans', 'Segment'),
  ('4', '1', 'Jacket', 'Segment'),
  ('5', '2', 'Shirt', 'Segment'),
  ('6', '2', 'Socks', 'Segment'),
  ('7', '3', 'Navy Oversized', 'Style'),
  ('8', '3', 'Black Straight', 'Style'),
  ('9', '3', 'Cream Relaxed', 'Style'),
  ('10', '4', 'Khaki Suit', 'Style'),
  ('11', '4', 'Indigo Rain', 'Style'),
  ('12', '4', 'Grey Fashion', 'Style'),
  ('13', '5', 'White Tee', 'Style'),
  ('14', '5', 'Teal Button Up', 'Style'),
  ('15', '5', 'Blue Polo', 'Style'),
  ('16', '6', 'Navy Solid', 'Style'),
  ('17', '6', 'White Striped', 'Style'),
  ('18', '6', 'Pink Fluro Polkadot', 'Style');

drop table if exists product_prices
CREATE TABLE product_prices (
  "id" INTEGER,
  "product_id" VARCHAR(6),
  "price" INTEGER
);

INSERT INTO product_prices
  ("id", "product_id", "price")
VALUES
  ('7', 'c4a632', '13'),
  ('8', 'e83aa3', '32'),
  ('9', 'e31d39', '10'),
  ('10', 'd5e9a6', '23'),
  ('11', '72f5d4', '19'),
  ('12', '9ec847', '54'),
  ('13', '5d267b', '40'),
  ('14', 'c8d436', '10'),
  ('15', '2a2353', '57'),
  ('16', 'f084eb', '36'),
  ('17', 'b9a74d', '17'),
  ('18', '2feb6b', '29');

drop table if exists product_details
CREATE TABLE product_details (
  "product_id" VARCHAR(6),
  "price" INTEGER,
  "product_name" VARCHAR(32),
  "category_id" INTEGER,
  "segment_id" INTEGER,
  "style_id" INTEGER,
  "category_name" VARCHAR(6),
  "segment_name" VARCHAR(6),
  "style_name" VARCHAR(19)
);

INSERT INTO product_details
  ("product_id", "price", "product_name", "category_id", "segment_id", "style_id", "category_name", "segment_name", "style_name")
VALUES
  ('c4a632', '13', 'Navy Oversized Jeans - Women', '1', '3', '7', 'Women', 'Jeans', 'Navy Oversized'),
  ('e83aa3', '32', 'Black Straight Jeans - Women', '1', '3', '8', 'Women', 'Jeans', 'Black Straight'),
  ('e31d39', '10', 'Cream Relaxed Jeans - Women', '1', '3', '9', 'Women', 'Jeans', 'Cream Relaxed'),
  ('d5e9a6', '23', 'Khaki Suit Jacket - Women', '1', '4', '10', 'Women', 'Jacket', 'Khaki Suit'),
  ('72f5d4', '19', 'Indigo Rain Jacket - Women', '1', '4', '11', 'Women', 'Jacket', 'Indigo Rain'),
  ('9ec847', '54', 'Grey Fashion Jacket - Women', '1', '4', '12', 'Women', 'Jacket', 'Grey Fashion'),
  ('5d267b', '40', 'White Tee Shirt - Men', '2', '5', '13', 'Mens', 'Shirt', 'White Tee'),
  ('c8d436', '10', 'Teal Button Up Shirt - Men', '2', '5', '14', 'Men', 'Shirt', 'Teal Button Up'),
  ('2a2353', '57', 'Blue Polo Shirt - Men', '2', '5', '15', 'Men', 'Shirt', 'Blue Polo'),
  ('f084eb', '36', 'Navy Solid Socks - Men', '2', '6', '16', 'Men', 'Socks', 'Navy Solid'),
  ('b9a74d', '17', 'White Striped Socks - Men', '2', '6', '17', 'Men', 'Socks', 'White Striped'),
  ('2feb6b', '29', 'Pink Fluro Polkadot Socks - Men', '2', '6', '18', 'Men', 'Socks', 'Pink Fluro Polkadot');


------------------------------------------------------------------------

-- for further ease in calculation we will add cost(aty*price) & bill_amt(cost-discount) column in table itself

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
