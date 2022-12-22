## 1. Write a query to display customer full name with their title (Mr/Ms), both first name and
-- last name are in upper case, customer email id, customer creation date and display customer’s category after applying below categorization rules:
-- i. IF customer creation date Year <2005 Then Category A
-- ii. IF customer creation date Year >=2005 and <2011 Then Category B
-- iii. iii)IF customer creation date Year>= 2011 Then Category C 
use orders;
SELECT
    CONCAT(case  when UPPER(CUSTOMER_GENDER)='F' then 'MRS.' when UPPER(CUSTOMER_GENDER)='M' then 'MR.'else '' end ,UPPER(CUSTOMER_FNAME), ' ', UPPER(CUSTOMER_LNAME)) AS 'Full Name',
    CUSTOMER_EMAIL AS 'Email',
    CUSTOMER_CREATION_DATE AS 'Creation Date',
    
    CASE
        WHEN YEAR(CUSTOMER_CREATION_DATE) < 2005 THEN 'Category A'
        WHEN YEAR(CUSTOMER_CREATION_DATE) >= 2005 AND YEAR(CUSTOMER_CREATION_DATE) < 2011 THEN 'Category B'
        WHEN YEAR(CUSTOMER_CREATION_DATE) >= 2011 THEN 'Category C'
    END AS 'Category'
FROM online_customer;

## 2. Write a query to display the following information for the products, which have not
-- been sold: product_id, product_desc, product_quantity_avail, product_price, inventory
-- values (product_quantity_avail*product_price), New_Price after applying discount as per
-- below criteria. Sort the output with respect to decreasing value of Inventory_Value. 
-- i) IF Product Price > 20,000 then apply 20% discount
-- ii) IF Product Price > 10,000 then apply 15% discount
-- iii) IF Product Price =< 10,000 then apply 10% discount
select   product_id , product_desc ,product_quantity_avail ,product_price ,(product_quantity_avail * product_price) as Inventory_Value,
case when product_price >20000 then ( product_price - (product_price * 0.2)) 
when  product_price >10000 then ( product_price - (product_price * 0.15)) 
when  product_price <=10000 then ( product_price - (product_price * 0.1)) end as New_price
  from product where product_id not in (select product_id from order_items)
order by (product_quantity_avail * product_price)  desc;

## 3. Write a query to display Product_class_code, Product_class_description, Count of
-- Product type in each product class, Inventory Value
-- (product_quantity_avail*product_price).
-- Information should be displayed for only those product_class_code which have more than
-- 1,00,000. Inventory Value. Sort the output with respect to decreasing value of
-- Inventory_Value.
select  pc.product_class_code,pc.product_class_desc,count(p.product_id) as Count_product,
sum(product_quantity_avail * product_price) as Inventory_Value
 from product p inner join product_class pc on p.product_class_code =pc.product_class_code
 group by product_class_code,pc.product_class_desc
 having Inventory_Value>100000
 order by Inventory_Value desc;
 
 ## 4. Write a query to display customer_id, full name, customer_email, customer_phone and
-- country of customers who have cancelled all the orders placed by them (USE SUBQUERY)
select CUSTOMER_ID, CONCAT(UPPER(CUSTOMER_FNAME), ' ', UPPER(CUSTOMER_LNAME)) AS 'Full Name', CUSTOMER_EMAIL, CUSTOMER_PHONE, ad.Country
 from online_customer oc inner join address ad on oc.address_id = ad.address_id
Where customer_id in (select customer_id from order_header where  order_status = 'Cancelled')
and customer_id not in (select customer_id from order_header where order_status !='Cancelled');

## 5. Write a query to display Shipper name, City to which it is catering, num of customer
-- catered by the shipper in the city and number of consignments delivered to that city for
-- Shipper DHL
Select S.Shipper_Name,A.city as Cateringcity,count(C.customer_id) as NumofCustomer,count(S.shipper_id) as Numberofconsignmentsdelivered 
from Shipper S
join order_header H on S.shipper_id=H.shipper_id
join online_customer C on C.customer_id=H.Customer_id 
join address A on A.Address_id = C.address_id
where S.Shipper_Name='DHL' and H.order_status ='Shipped'
group by A.city;

## 6. Write a query to display product_id, product_desc, product_quantity_avail, quantity sold
-- and show inventory Status of products as below as per below condition:
-- i. For Electronics and Computer categories, if sales till date is Zero then show 'No
-- Sales in past, give discount to reduce inventory', if inventory quantity is less than
-- 10% of quantity sold, show 'Low inventory, need to add inventory', if inventory
-- quantity is less than 50% of quantity sold, show 'Medium inventory, need to add
-- some inventory', if inventory quantity is more or equal to 50% of quantity sold,
-- show 'Sufficient inventory'
-- ii. For Mobiles and Watches categories, if sales till date is Zero then show 'No Sales in
-- past, give discount to reduce inventory', if inventory quantity is less than 20% of
-- quantity sold, show 'Low inventory, need to add inventory', if inventory quantity is
-- less than 60% of quantity sold, show 'Medium inventory, need to add some
-- inventory', if inventory quantity is more or equal to 60% of quantity sold, show
-- 'Sufficient inventory'
-- iii. Rest of the categories, if sales till date is Zero then show 'No Sales in past, give
-- discount to reduce inventory', if inventory quantity is less than 30% of quantity
-- sold, show 'Low inventory, need to add inventory', if inventory quantity is less than
-- 70% of quantity sold, show 'Medium inventory, need to add some inventory', if
-- inventory quantity is more or equal to 70% of quantity sold, show 'Sufficient
-- inventory'
select p.product_id,p.PRODUCT_DESC,sum(p.PRODUCT_QUANTITY_AVAIL) PRODUCT_QUANTITY_AVAIL,
sum(oi.PRODUCT_QUANTITY) as QUANTITY_Sold,
case when pc.PRODUCT_CLASS_DESC in ('Electronics','Computer') then
case  when 100-((sum(PRODUCT_QUANTITY) /sum(p.PRODUCT_QUANTITY_AVAIL) )*100)= 0 then  'No Sales in past, give discount to reduce inventory'
when 100-((sum(PRODUCT_QUANTITY) /sum(p.PRODUCT_QUANTITY_AVAIL) )*100) < 10 then  'Low inventory, need to add inventory'
when 100-((sum(PRODUCT_QUANTITY) /sum(p.PRODUCT_QUANTITY_AVAIL) )*100) < 50 then  'Medium inventory, need to add some inventory'
when 100-((sum(PRODUCT_QUANTITY) /sum(p.PRODUCT_QUANTITY_AVAIL) )*100) >= 50 then  'Sufficient inventory' end
when pc.PRODUCT_CLASS_DESC in ('Mobiles','Watches') then
    case  when 100-((sum(PRODUCT_QUANTITY) /sum(p.PRODUCT_QUANTITY_AVAIL) )*100)= 0 then  'No Sales in past, give discount to reduce inventory'
when 100-((sum(PRODUCT_QUANTITY) /sum(p.PRODUCT_QUANTITY_AVAIL) )*100) < 20 then  'Low inventory, need to add inventory'
when 100-((sum(PRODUCT_QUANTITY) /sum(p.PRODUCT_QUANTITY_AVAIL) )*100)< 60 then  'Medium inventory, need to add some inventory'
when 100-((sum(PRODUCT_QUANTITY) /sum(p.PRODUCT_QUANTITY_AVAIL) )*100)>= 60 then  'Sufficient inventory' end
else 
    case  when 100-((sum(PRODUCT_QUANTITY) /sum(p.PRODUCT_QUANTITY_AVAIL) )*100) = 0 then  'No Sales in past, give discount to reduce inventory'
when 100-((sum(PRODUCT_QUANTITY) /sum(p.PRODUCT_QUANTITY_AVAIL) )*100) < 30 then  'Low inventory, need to add inventory'
when 100-((sum(PRODUCT_QUANTITY) /sum(p.PRODUCT_QUANTITY_AVAIL) )*100) < 70 then  'Medium inventory, need to add some inventory'
when 100-((sum(PRODUCT_QUANTITY) /sum(p.PRODUCT_QUANTITY_AVAIL) )*100) >= 70 then  'Sufficient inventory' end
end  as Inventory_status
from product p inner join 
product_class pc on p.product_class_code =pc.product_class_code
inner join order_items oi on oi.product_id= p.product_id
group by p.product_id ;

## 7. Write a query to display order_id and volume of the biggest order (in terms of volume)
-- that can fit in carton id 10
select oi.Order_ID,sum(p.len*p.width*p.height*oi.Product_Quantity) as Volume
from Product p
inner join Order_Items oi
on p.Product_ID = oi.Product_ID
group by oi.Order_ID
having Volume
<= (select (len*width*height) as Volume from Carton where CARTON_ID = 10)
order by Volume desc
limit 1;

## 8. Write a query to display customer id, customer full name, total quantity and total value
-- (quantity*price) shipped where mode of payment is Cash and customer last name starts
-- with 'G'
select c.Customer_ID, concat ( c.Customer_Fname," ",c.Customer_Lname ) as Customer_Full_Name,
sum (oi.product_quantity) as Total_Quantity, sum (oi.product_quantity*p.product_price) as Total_Value
from ONLINE_CUSTOMER c
inner join ORDER_HEADER oh on c.Customer_ID = oh.Customer_ID
inner join ORDER_ITEMS oi on oi.order_ID = oh.Order_ID
inner join product p on p.Product_ID = oi.Product_ID
where oh.payment_mode = 'cash'
and c.Customer_Lname like 'G%'
and oh.ORDER_STATUS = 'Shipped'
group by c.Customer_ID;

## 9. Write a query to display product_id, product_desc and total quantity of products which
-- are sold together with product id 201 and are not shipped to city Bangalore and New
-- Delhi.
-- Display the output in descending order with respect to the tot_qty.
Select P.product_Id,p.Product_Desc,sum(o.product_quantity) as Total_quantity from online_customer c
join order_header H on c.customer_id=h.customer_id
join order_items o on o.order_id=h.order_id
join product p on p.product_id=o.product_id
join Address A on A.address_id=c.address_id
where p.product_id in 
(Select Product_id from order_items where ORDER_ID in (Select Order_id from order_items where product_id=201)) 
and a.city not in ('Bangalore','New Delhi')
group by P.product_Id
order by sum(o.product_quantity) desc;

## 10. Write a query to display the order_id,customer_id and customer fullname, total
-- quantity of products shipped for order ids which are even and shipped to address where
-- pincode is not starting with "5"
Select o.order_id,c.customer_id,concat(c.Customer_fname,c.customer_Lname) as FullName,sum(o.product_quantity)as TotalQuantity from online_customer c
join order_header H on c.customer_id=h.customer_id
join order_items o on o.order_id=h.order_id
join Address A on A.address_id=c.address_id
where a.pincode not like '5%' and o.order_id %2 =0
group by o.order_id,c.customer_id
order by customer_id