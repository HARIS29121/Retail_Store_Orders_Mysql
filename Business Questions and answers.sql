use orders;

/* # 1. Write a query to display customer full name with their title (Mr/Ms), 
-- both first name and last name are in upper case, customer email id, 
-- customer creation date and display customer’s category after applying below 
-- categorization rules: 
-- 1) IF customer creation date Year <2005 Then Category A 
-- 2) IF customer creation date Year >=2005 and <2011 Then Category B 
-- 3) IF customer creation date Year>= 2011 Then Category C 
# Hint: Use CASE statement, no permanent change in table required. 
# NOTE: TABLES to be used - ONLINE_CUSTOMER TABLE] */

SELECT concat((case when customer_gender = 'F' then 'Ms.' when customer_gender = 'M' then 'Mr.' end),' ', upper(customer_fname),' ',upper(customer_lname)) as Customer_Full_Name, 
CUSTOMER_EMAIL,CUSTOMER_CREATION_DATE, 
case when year(customer_creation_date) < '2005' then  'Category A' 
	 when year(customer_creation_date)>= '2005' and year(customer_creation_date) < '2011' then 'Category B'
     when year(customer_creation_date) >= '2011' then  'Category C' end as 'Customer_Category'
from online_customer;

/* #2. Write a query to display the following information for the products, which have not been sold: 
product_id, product_desc, product_quantity_avail, product_price, inventory values 
-- (product_quantity_avail*product_price), New_Price after applying discount as per below criteria. 
-- Sort the output with respect to decreasing value of Inventory_Value. 
-- 1) IF Product Price > 200,000 then apply 20% discount 
-- 2) IF Product Price > 100,000 then apply 15% discount 
-- 3) IF Product Price =< 100,000 then apply 10% discount 
# Hint: Use CASE statement, no permanent change in table required. 
# [NOTE: TABLES to be used - PRODUCT, ORDER_ITEMS TABLE] */

select p.product_id,p.product_desc,p.product_quantity_avail, p.product_price, p.product_quantity_avail*p.product_price AS Inventory_Value,
case when p.product_price > 200000 then (p.product_price - (p.product_price*0.20))
	 when p.product_price > 100000 and  p.product_price <= 200000 then (p.product_price - (p.product_price*0.15))
     when p.product_price <= 100000 then (p.product_price - (p.product_price*0.10)) end as New_Price
from product p
left join order_items o on p.PRODUCT_ID = o.PRODUCT_ID
where o.PRODUCT_ID is null
order by Inventory_Value desc;

/*#3. Write a query to display Product_class_code, Product_class_description, Count of Product type in 
each product 
-- class, Inventory Value (p.product_quantity_avail*p.product_price). Information should be 
displayed for only those product_class_code which have more than 1,00,000 
-- Inventory Value. Sort the output with respect to decreasing value of Inventory_Value. 
# NOTE: TABLES to be used - PRODUCT_CLASS, PRODUCT_CLASS_CODE] */

select p.product_class_code, pc.product_class_desc, count(p.product_id) AS Total_product_types, 
(p.product_quantity_avail*p.product_price) AS Inventory_Value from product p
inner join product_class pc on p.PRODUCT_CLASS_CODE = pc.PRODUCT_CLASS_CODE
group by pc.PRODUCT_CLASS_DESC
having Inventory_Value > 100000
order by Inventory_Value desc;

/* #4. Write a query to display customer_id, full name, customer_email, customer_phone and country of 
customers who 
-- have cancelled all the orders placed by them 
-- (USE SUB-QUERY) 
-- [NOTE: TABLES to be used - ONLINE_CUSTOMER, ADDRESSS, OREDER_HEARDER] */

select oc.customer_id, concat(oc.customer_fname,' ', oc.customer_lname) as Full_Name , oc.customer_email,oc.customer_phone,ad.country
from online_customer oc
left join address ad on oc.address_id = ad.address_id
where oc.customer_id in (select customer_id from order_header where ORDER_STATUS = 'cancelled' );


/* #5. Write a query to display Shipper name, City to which it is catering, num of customer catered by 
the shipper in the city and number of consignments delivered to that city for Shipper DHL 
[NOTE: TABLES to be used - SHIPPER,ONLINE_CUSTOMER, ADDRESSS, OREDER_HEARDER] */

select s.shipper_name,a.city,count(distinct oc.customer_id) AS No_of_Customers_In_city,count(a.address_id) AS consignments_delivered
from online_customer oc
join address a on oc.address_id = a.address_id
join order_header oh on oh.customer_id = oc.customer_id
join shipper s on s.shipper_id = oh.shipper_id
where s.shipper_name = 'DHL'
group by a.city
order by shipper_name;

 /* #6. Write a query to display product_id, product_desc, product_quantity_avail, quantity sold, quantity 
available and 
-- show inventory Status of products as below as per below condition: 
-- a. For Electronics and Computer categories, if sales till date is Zero then show 
-- 'No Sales in past, give discount to reduce inventory', if inventory quantity is less than 10% of 
quantity sold, 
-- show 'Low inventory, need to add inventory', if inventory quantity is less than 50% of quantity 
sold, 
-- show 'Medium inventory, need to add some inventory', if inventory quantity is more or equal to 
50% of quantity sold, 
-- show 'Sufficient inventory' 
-- b. For Mobiles and Watches categories, if sales till date is Zero then show 
-- 'No Sales in past, give discount to reduce inventory', if inventory quantity is less than 20% of 
quantity sold, 
-- show 'Low inventory, need to add inventory', if inventory quantity is less than 60% of quantity 
sold, 
-- show 'Medium inventory, need to add some inventory', if inventory quantity is more or equal to 
60% of quantity sold, 
-- show 'Sufficient inventory' 
-- c. Rest of the categories, if sales till date is Zero then show 
-- 'No Sales in past, give discount to reduce inventory', if inventory quantity is less than 30% of 
quantity sold, 
-- show 'Low inventory, need to add inventory', if inventory quantity is less than 70% of quantity 
sold, 
-- show 'Medium inventory, need to add some inventory', if inventory quantity is more or equal to 
70% of quantity sold, 
-- show 'Sufficient inventory' 
-- (USE SUB-QUERY) 
-- [NOTE: TABLES to be used - PRODUCT, PRODUCT_CLASS, ORDER_HEADER] */

-- Comment: Order_header table had no information about the product quantity ordered. So I used order items table instead of Order_header table to get the required input as per the question.

select a.*, case when a.product_class_desc = 'Electronics' or a.product_class_desc = 'Computer' then
					  case when a.Quantity_sold = 0 then 'No Sales in past, give discount to reduce inventory'
						   when a.product_quantity_avail < a.Quantity_sold*0.10 then 'Low inventory, need to add inventory'
                           when a.Quantity_sold*0.10 >= a.product_quantity_avail < a.Quantity_sold*0.50 then 'Medium inventory, need to add some inventory'
                           when a.product_quantity_avail >= a.Quantity_sold*0.50 then 'Sufficient inventory'  end
                 when a.product_class_desc = 'Mobiles' or a.product_class_desc = 'Watches' then
					  case when a.Quantity_sold = 0 then 'No Sales in past, give discount to reduce inventory'
                           when a.product_quantity_avail < a.Quantity_sold*0.20 then 'Low inventory, need to add inventory'
                           when a.Quantity_sold*0.20 >= a.product_quantity_avail < a.Quantity_sold*0.60 then 'Medium inventory, need to add some inventory'
                           when a.product_quantity_avail >= a.Quantity_sold*0.60 then 'Sufficient inventory' end
				 else 
					  case when a.Quantity_sold = 0 then 'No Sales in past, give discount to reduce inventory'
                           when a.product_quantity_avail < a.Quantity_sold*0.30 then 'Low inventory, need to add inventory'
                           when a.Quantity_sold*0.30 >= a.product_quantity_avail < a.Quantity_sold*0.70 then 'Medium inventory, need to add some inventory'
                           when a.product_quantity_avail >= a.Quantity_sold*0.70 then 'Sufficient inventory' end
				end as Inventory_Status
from
(select p.product_id,p.product_desc,p.product_quantity_avail,pc.product_class_desc,COALESCE(sum(oi.product_quantity),0) as Quantity_Sold, p.product_quantity_avail as Quantity_Available from product p
left join order_items oi on p.product_id = oi.product_id
join  product_class pc on p.product_class_code = pc.product_class_code
group by p.product_id)a
order by a.product_id;
 
 
/* #7. Write a query to display order_id and volume of the biggest order (in terms of volume) that can fit 
in carton id 10 
-- [NOTE: TABLES to be used - CARTON, ORDER_ITEMS, PRODUCT] */

select a.order_id, sum(a.Biggest_Order) as Volume_of_biggest_order from
(select oi.order_id, p.len*p.width*p.height*oi.product_quantity as Biggest_Order
from product p
inner join order_items oi on p.product_id = oi.product_id)a
group by a.order_id
having Volume_of_biggest_order <= (select len*width*height from carton where carton_id=10)
order by Biggest_Order desc limit 1;


/* #8. Write a query to display customer id, customer full name, total quantity and total value 
(quantity*price) shipped where mode of payment is Cash and customer last name starts with 'G' 
-- [NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER] */

select oc.customer_id, concat(oc.customer_fname,' ',oc.customer_lname) as Customer_Full_Name, sum(oi.product_quantity) as Total_Quantity, sum(oi.product_quantity*p.product_price) as Total_Price
from order_header oh
inner join online_customer oc on oc.customer_id = oh.customer_id
inner join order_items oi on oh.order_id = oi.order_id
inner join product p on oi.product_id = p.product_id
where oh.order_status = 'Shipped' and oh.payment_mode = 'Cash' and oc.customer_lname like 'G%'
group by oc.customer_id,Customer_Full_Name;

/* #9. Write a query to display product_id, product_desc and total quantity of products 
 which are sold together with product id 201 and are not shipped to city Bangalore and New Delhi. 
-- Display the output in descending order with respect to tot_qty. 
-- (USE SUB-QUERY) 
-- [NOTE: TABLES to be used - order_items, product,order_head, online_customer, address]  */

select c.product_id as Product_ID,p.product_desc,sum(c.product_quantity) as Total_Quantity
from 
(select b.*,a.product_id as actual_product_id, b.product_id as bought_together
from order_items a
inner join order_items b
on a.order_id = b.order_id and  a.product_id != b.product_id
where a.product_id = 201) c
inner join product p on p.product_id = c.product_id
inner join order_header oh on oh.order_id = c.order_id
inner join online_customer oc on oc.customer_id = oh.customer_id
inner join address ad on ad.address_id = oc.address_id
where city not in ('Bangalore','New Delhi')
group by c.product_id
order by Total_Quantity desc;

/* #10 Write a query to display the order_id,customer_id and customer fullname 
 -- as total quantity of products shipped for order ids which are even 
 -- and shipped to address where pincode is not starting with "5" 
 -- [NOTE: TABLES to be used - online_customer,Order_header, order_items,address] */

select oh.order_id, oh.customer_id, concat(oc.customer_fname,' ',oc.customer_lname) as Customer_Full_Name, sum(oi.product_quantity) as Total_Quantity
from order_header oh 
join online_customer oc on oh.customer_id = oc.customer_id
join order_items oi on oh.order_id = oi.order_id
join address a on oc.address_id = a.address_id
where (oi.order_id % 2) = 0  and oh.order_status = 'Shipped' and a.pincode not like '5%'
group by oh.order_id,oh.customer_id,Customer_Full_Name;
