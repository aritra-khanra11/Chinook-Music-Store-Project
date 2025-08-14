use chinook;
-- album 
select *
from album
where 
	album_id is null
    or title is null
    or artist_id is null;

-- artist
select *
from artist
where 
	artist_id is null
    or name is null;

    
-- customer
desc customer;
select * from customer;
select *
from
	customer
where 
	customer_id is null
	or first_name is null
	or last_name is null 
	or company is null
	or address is null  
	or city is null  
	or state is null 
	or country is null 
	or postal_code is null 
	or phone is null 
	or fax is null  
	or email is null 
	or support_rep_id is null;
    
select
	customer_id,
    first_name,
    last_name,
    coalesce(company, 'No company specified') as company,
    coalesce(address, 'No Address Available') as address,
    coalesce(city, 'Not Provided') as first_name,
    coalesce(state, 'Not Provided') as first_name,
    coalesce(country,'Not Provovided') as country,
    coalesce(postal_code,'Not Available') as postal_code,
    coalesce(phone,'Not Provided') as phone,
    coalesce(fax,'Not Available') as fax,
    email,
    coalesce(support_rep_id,'Not Taken') as support_rep_id
    from customer;
    

-- employee
select *
from employee
where 
		title is null
        or reports_to is null
        or birthdate is null
        or hire_date is null
        or address is null
        or city is null
        or state is null
        or country is null
        or postal_code is null
        or phone is null
        or fax is null
        or email is null;
        
	select 
		employee_id,
        last_name,
        first_name,
		coalesce(reports_to,'NA') as reports_to,
        birthdate,
        hire_date,
        address,
        city,
        state,
        country,
        postal_code,
        phone,
        fax,
        email
from employee ;    

-- genre
select * 
from genre
where name is null;

-- invoice
select *
from invoice
where invoice_date is null
or billing_address is null
or billing_city is null
or billing_state is null
or billing_country is null
or billing_postal_code is null;

-- invoice line
desc invoice_line;

-- Media_type
desc media_type;
select *
from media_type
where 
	name is null;
    

-- Playlist
desc playlist;
select *
from playlist
where name is null;


-- Playlist track
desc playlist_track;


-- Track
desc track;
select *
from track
where 
	album_id is null
    or genre_id is null
	or composer is null
    or bytes is null;
    
select 
track_id,
name,
album_id,
media_type_id,
genre_id,
coalesce(composer,'Not Provided') as composer,
milliseconds,
bytes,
unit_price
from track;

-- checking top selling track
select * from invoice;
select * from invoice_line;
select * from track;
select * from customer;

select t.track_id, t.name, sum(il.quantity) as total_quantity
from 
	track t
    inner join
    invoice_line il on t.track_id= il.track_id
    inner join 
    invoice i on il.invoice_id= i.invoice_id
    inner join 
    customer c on i.customer_id= c.customer_id
where c.country= 'USA'
group by t.track_id, t.name
order by total_quantity desc;

    
-- Top Artist
select ar.artist_id, ar.name, sum(il.quantity) as total_count
from 
	customer c
    inner join
	invoice i on c.customer_id= i.customer_id
    inner join
    invoice_line il on i.invoice_id= il.invoice_id
    inner join
    track t on il.track_id= t.track_id
    inner join
    album a on t.album_id= a.album_id
    inner join
    artist ar on a.artist_id= ar.artist_id
where c.country= 'USA'
group by ar.artist_id, ar.name
order by total_count desc;

-- Famous genour

with top_artist as(select ar.artist_id, ar.name, t.genre_id, sum(il.quantity) as total_count
                   from 
	                   customer c
				       inner join
	                   invoice i on c.customer_id= i.customer_id
				       inner join
                       invoice_line il on i.invoice_id= il.invoice_id
                       inner join
                       track t on il.track_id= t.track_id
				       inner join
                       album a on t.album_id= a.album_id
                       inner join
                       artist ar on a.artist_id= ar.artist_id
					where c.country= 'USA'
                    group by ar.artist_id, ar.name, t.genre_id
                    order by total_count desc
                  )
select t.genre_id,artist_id, g.name as genre_type, total_count
from
	top_artist t
	inner join 
	genre g on t.genre_id= g.genre_id
order by total_count desc;


-- Customer Demographic Breakdown
select 
	country, 
    coalesce(state, 'NA') as state,
    city,
    count(customer_id) as count_of_customer
from customer
group by country,state,city
order by count(customer_id) desc;


-- Total revenue and number of invoices for each country, state, and city
select 
	c.country,
    coalesce(c.state,'NA') as state, 
    c.city, 
    sum(i.total) as total_revenue, 
    count(i.invoice_id) count_invoice
from 
	customer c
    inner join
    invoice i on c.customer_id= i.customer_id
group by c.country, c.state, c.city
order by total_revenue desc,count_invoice desc ;



-- Top 5 Customers by total  revenue each country
with customer_rank as(select
	c.customer_id,
    concat(c.first_name, ' ', c.last_name) as customer_name,
    c.country,
    sum(i.total) as total_revenue,
    rank() over(partition by c.country order by sum(i.total) desc) as ranking
from
	customer c
    inner join
    invoice i on c.customer_id= i.customer_id
    group by c.customer_id, c.country)
select 
	customer_id,
    customer_name,
    country,
    total_revenue
from customer_rank
where ranking<=5
order by country,ranking;


-- Identify the top-selling track for each customer
with customer_tracks as (select
	c.customer_id,
    concat(c.first_name, ' ', c.last_name) as customer_name,
    t.name as track_name,
    sum(il.quantity) as total_quantity,
    row_number() over (partition by c.customer_id order by sum(il.quantity) desc) as top_rank
  from 
  customer c
  inner join 
  invoice i on c.customer_id = i.customer_id
  inner join 
  invoice_line il on i.invoice_id = il.invoice_id
  inner join 
  track t on il.track_id = t.track_id
  group by c.customer_id, c.first_name, c.last_name, t.track_id, t.name
)
select
  customer_id,
  customer_name,
  track_name,
  round(total_quantity,2) as total_quantity
from customer_tracks
where top_rank = 1
order by customer_id;
    
   --  frequency of purchases
   select 
	c.customer_id,
    concat(first_name, ' ', last_name) as customer_name,
    year(i.invoice_date) as years,
    count(i.invoice_id) as purchase_quantity
   from 
		customer  c
        inner join
        invoice i on c.customer_id= i.customer_id
	group by c.customer_id, customer_name, years
    order by c.customer_id, years asc;
    
    -- Average order value
    select
		c.customer_id,
        concat(c.first_name,' ', c.last_name) as customer_name,
        avg(i.total) as average_value
    from 
		customer c
        inner join 
        invoice i on c.customer_id= i.customer_id
	group by c.customer_id, customer_name
    order by average_value desc;
    
    

-- Customer churn rate
with invoice_years as(select
	customer_id,
	year(invoice_date) as year
	from 
	invoice
	group by customer_id, year),
year_pairs as (select distinct
	prev.year as prev_year,
	next.year as next_year
				from invoice_years prev
				join invoice_years next on next.year = prev.year + 1
				),
latest_pair as (select *
				from
					year_pairs
				order by prev_year desc
				limit 1
),
active_prev_year as (select customer_id
                      from invoice_years
                    where year = (select prev_year from latest_pair)
                   ),
active_next_year as (select 
						customer_id
					from invoice_years
					where year = (select next_year from latest_pair)
                    ),
churned_customers as (select 
						customer_id
						from active_prev_year
						where customer_id not in (select customer_id from active_next_year)
					)
select
  (select count(*) from churned_customers) * 100.0 /
  (select count(*) from active_prev_year) as churn_rate_percent;


-- Genre-wise sales percentage analysis for USA customers
with genre_sale as(select 
	g.genre_id,
	g.name,
    sum(i.total) as total_sales
from 
	customer c
    inner join 
	invoice i on c.customer_id= i.customer_id
    inner join
    invoice_line il on i.invoice_id= il.invoice_id
    inner join
    track t on il.track_id= t.track_id
    inner join
    genre g on t.genre_id= g.genre_id
where 
	c.country= 'USA'
group by g.genre_id, g.name),
total as (select 
    sum(total_sales) as sales
    from genre_sale)
select 
	genre_id,
    name,
    total_sales,
    round(total_sales/(select sales from total)*100,2) as sales_percentage
from genre_sale;

-- Top selling artists by genre in the USA
    with artist_genre as(select 
	a.artist_id,
    ar.name as artist_name,
	g.name as genre_name,
    sum(i.total) as total_sales,
    dense_rank() over(partition by g.name order by sum(i.total) desc) as ranking
from 
	customer c
    inner join 
	invoice i on c.customer_id= i.customer_id
    inner join
    invoice_line il on i.invoice_id= il.invoice_id
    inner join
    track t on il.track_id= t.track_id
    inner join
    genre g on t.genre_id= g.genre_id
    inner join 
    album a on t.album_id= a.album_id
    inner join
    artist ar on a.artist_id= ar.artist_id
where 
	c.country= 'USA'
group by a.artist_id, artist_name, g.name
order by total_sales)
select *
from artist_genre
where ranking= 1
order by total_sales desc;


-- Customer who purchase atlest 3 gener
with purchase_counting as(select 
	c.customer_id,
    concat(c.first_name,' ', c.last_name) as customer_name,
    g.name as genre_name,
    count(t.genre_id) as purchase_count
from 
	customer c
    inner join
    invoice i on c.customer_id= i.customer_id
    inner join  
    invoice_line il on i.invoice_id= il.invoice_id
    inner join
    track t on il.track_id= t.track_id
    inner join 
    genre g on t.genre_id= g.genre_id
group by c.customer_id, customer_name, genre_name),
ranking as(select *, 
	row_number() over(partition by customer_id order by purchase_count desc) as ranks
from purchase_counting)
select 
	customer_id,
    customer_name,
    genre_name,
    purchase_count
from ranking
where ranks>= 3; 


-- Rank genres based on their sales performance in the USA
select 
	g.genre_id,
    g.name as genre_name,
    sum(i.total) as sales_amount,
    dense_rank() over(order by sum(i.total) desc) as ranking
from 
	customer c
    inner join
    invoice i on c.customer_id= i.customer_id
    inner join  
    invoice_line il on i.invoice_id= il.invoice_id
    inner join
    track t on il.track_id= t.track_id
    inner join 
    genre g on t.genre_id= g.genre_id
    group by g.genre_id, genre_name;
    
    
-- Identify customers who have not made a purchase in the last 3 months    
select 
	c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name
from 
	customer c
	left join 
    invoice i ON c.customer_id = i.customer_id
group by c.customer_id, customer_name
having max(i.invoice_date) < date_add(CURDATE(), INTERVAL -3 MONTH);


    
-- Recommend the three albums from the new record label that should be prioritised for advertising and promotion in the USA based on genre sales analysis.
select
	g.name as genre_name,
    a.title as album_name,
    sum(i.total) as total_sales,
    dense_rank() over (order by sum(i.total) desc) as ranks
from 
	customer c
    inner join
    invoice i on c.customer_id= i.customer_id
    inner join
    invoice_line il on i.invoice_id= il.invoice_id
    inner join 
    track t on il.track_id= t.track_id
    inner join
    genre g on t.genre_id= g.genre_id
    inner join
    album a on t.album_id= a.album_id
    where 
		c.country = 'USA'
	group by genre_name, album_name
    order by ranks 
    limit 3;
    
    
 --    Determine the top-selling genres in countries other than the USA and identify any commonalities or differences.
 select 
	g.name as genre_name,
    sum(il.quantity) as quantity
 from 
	customer c
    inner join
    invoice i on c.customer_id= i.customer_id
    inner join
    invoice_line il on i.invoice_id= il.invoice_id
    inner join 
    track t on il.track_id= t.track_id
    inner join
    genre g on t.genre_id= g.genre_id
    inner join
    album a on t.album_id= a.album_id
where
	c.country<> 'USA'
group by genre_name
order by quantity desc;


-- Customer Purchasing Behavior Analysis: How do the purchasing habits (frequency, basket size, spending amount) of long-term customers differ from those of new customers
with purchase_stat as(select
    c.customer_id,count(il.invoice_id) as purchase_quantity,sum(il.quantity) as total_product_purchase,sum(i.total) as total_spent,
    avg(i.total) as avg_spent_per_order,
    datediff(max(i.invoice_date), min(i.invoice_date)) as customer_lifetime_days
from 
	customer c
    inner join
    invoice i on c.customer_id= i.customer_id
    inner join
    invoice_line il on i.invoice_id= il.invoice_id
    group by c.customer_id),
customer_segment as(select
		customer_id,purchase_quantity,total_product_purchase,
        total_spent,
        avg_spent_per_order,
        customer_lifetime_days,
        case 
        when customer_lifetime_days < 365 then 'recent'
        else 'long-term'
        end as customer_category
        from purchase_stat
    )
    select 
		customer_category,
		round(avg(purchase_quantity),2) as avg_purchase_frequncy,
		round(avg(total_product_purchase),2) as avg_basket_size,
		round(avg(total_spent),2) as avg_spending,
		round(avg(avg_spent_per_order),2) as avg_order_value
	from customer_segment
    group by customer_category;
    
-- for check the first purchasing date because all the customer show as long_term(old) customer    
select c.customer_id,c.first_name,max(i.invoice_date),min(invoice_date)
from customer c
inner join invoice i on c.customer_id= i.customer_id
group by c.customer_id,c.first_name
order by c.customer_id;
    

-- affinity of genre
with track_combine as(select 
	il1.track_id as track1,
    il2.track_id as track2,
    count(*) as purchase_toagrther
from 
	invoice_line il1 inner join invoice_line il2 on il1.invoice_id= il2.invoice_id and il1.track_id<il2.Track_id
	group by track1,track2),
combine_genre as(select t1.genre_id as genre1, t2.genre_id as genre2, count(*) time_of_purchase_together
from 
	track_combine as t
    inner join track t1 on t.track1= t1.track_id 
    inner join track t2 on t.track2= t2.track_id
    where t1.genre_id<>t2.genre_id
	group by genre1, genre2)
    select 
		g1.name as genre_name1, g2.name as genre_name2, time_of_purchase_together
    from 
		combine_genre cg
        inner join
        genre as g1 on cg.genre1= g1.genre_id
        inner join 
        genre as g2 on cg.genre2= g2.genre_id
	order by time_of_purchase_together desc;
    
    
    -- affinity of artist
    with track_combine as(select 
	il1.track_id as track1,
    il2.track_id as track2,
    count(*) as purchase_toagrther
from 
	invoice_line il1 inner join invoice_line il2 on il1.invoice_id= il2.invoice_id and il1.track_id<il2.Track_id
	group by track1,track2),
artist_combination as(select ar1.artist_id as artist1, ar2.artist_id as artist2, count(*) time_of_purchase_together
from 
	track_combine as t
    inner join track t1 on t.track1= t1.track_id 
    inner join track t2 on t.track2= t2.track_id
    inner join album a1 on t1.album_id= a1.album_id
    inner join album a2 on t2.album_id= a2.album_id
    inner join artist ar1 on a1.artist_id= ar1.artist_id
    inner join artist ar2 on a2.artist_id= ar2.artist_id
where ar1.artist_id<> ar2.artist_id
group by artist1, artist2)
select ar1.name as artist_name_1,
		ar2.name as artist_name_2, time_of_purchase_together
from 
	artist_combination ar
    inner join artist ar1 on ar.artist1= ar1.artist_id
    inner join artist ar2 on ar.artist2= ar2.artist_id
order by time_of_purchase_together desc;


-- album affinity analysis
 with track_combine as(select 
	il1.track_id as track1,
    il2.track_id as track2,
    count(*) as purchase_toagrther
from 
	invoice_line il1 inner join invoice_line il2 on il1.invoice_id= il2.invoice_id and il1.track_id<il2.Track_id
	group by track1,track2),
album_combination as(select a1.album_id as album1, a1.album_id as album2, count(*) time_of_purchase_together
from 
	track_combine as t
    inner join track t1 on t.track1= t1.track_id 
    inner join track t2 on t.track2= t2.track_id
    inner join album a1 on t1.album_id= a1.album_id
    inner join album a2 on t2.album_id= a2.album_id
where a1.album_id<> a2.album_id
group by album1,album2)
select a.title as album_name,
		a1.title as album_name,
        time_of_purchase_together
from 
	album_combination ac
    inner join album a on ac.album1= a.album_id
    inner join album a1 on ac.album2= a1.album_id
order by time_of_purchase_together desc;
    
    

-- customer purchasing behaviour by region
with customer_purchase as (select 
    c.customer_id,
    c.country,
    coalesce(c.state, 'not available') as state,
    c.city,
    count(i.invoice_id) as total_purchases,
    sum(i.total) as total_spending,
    avg(i.total) as avg_order_value
  from customer c
  inner join 
  invoice i on c.customer_id = i.customer_id
  group by c.customer_id, c.country, c.state, c.city)
select 
  country,
  state,
  city,
  count(customer_id) as total_customers,
  sum(total_purchases) as total_purchases,
  round(sum(total_spending),2) as total_spending,
  round(avg(avg_order_value),2) as avg_order_value,
  round(avg(total_purchases),2) as avg_purchase_frequency
from customer_purchase
group by country, state, city
order by total_spending desc;


--  Churn Rate by Region 
with region_churn_rate as (select 
	c.customer_id,c.country,
	coalesce(c.state,"Not Available") as state,
	c.city,max(i.invoice_date) as latest_date_purchased
from 
    customer c 
	inner join 
    invoice i on c.customer_id = i.customer_id
group by c.customer_id,c.country,state,c.city),
churn_customer as (select 
	country,state,city,
	count(customer_id) as churn_customer
from region_churn_rate
where 
	latest_date_purchased < date_sub(curdate() , interval 1 year)
group by country,state,city)
select 
	cc.country,
    cc.state,
    cc.city,cc.churn_customer,
	count(c.customer_id) as total_customer,
	cc.churn_customer/count(c.customer_id)*100 as churn_rate
from 
	churn_customer cc
	inner join 
	customer c on cc.country = c.country and cc.state = c.state and cc.city = c.city
group by cc.country,cc.state,cc.city,cc.churn_customer;




-- Customer Risk Profiling: Based on customer profiles (age, gender, location, purchase history)
with latest_invoice_date as (select 
	max(invoice_date) as latest_date
from invoice
),
customer_purchase_summary as (select c.customer_id, c.country, coalesce(c.state,'Not Available') as state, c.city, count(i.invoice_id) as total_orders,
	sum(i.total) as total_spent, avg(i.total) as avg_purchase_amount, sum(il.quantity) as total_quantity,
	avg(il.quantity) as avg_quantity, max(i.invoice_date) as last_purchase_date
    from 
    customer c inner join 
    invoice i on c.customer_id = i.customer_id
    inner join invoice_line il on i.invoice_id = il.invoice_id
    group by c.customer_id, c.country, state, c.city
),
customer_risk_profile as (select 
	c.*,
	case 
		when c.last_purchase_date < date_sub((select latest_date from latest_invoice_date), interval 1 year) 
		then 'Risk'
		when c.total_spent < 1000
		then 'Medium Risk'
		else 'Low Risk'
        end as risk_level
from customer_purchase_summary c
)
select *
from customer_risk_profile
order by risk_level desc, total_spent;



select 
	c.customer_id,
    concat(c.first_name,' ', c.last_name) as customer_name,
    c.country,
    coalesce(c.state, 'Not Available') as state,
    min(i.invoice_date) as first_purchase,
    max(i.invoice_date) as last_purchase,
    datediff(max(i.invoice_date),min(i.invoice_date)) as tenure,
	count(i.invoice_id) as purchase_count,
    sum(i.total) as total_spend,
    round(avg(i.total),2) as avrage_spend,
    case 
		when max(i.invoice_date)< date_sub(curdate(), interval 1 year) then 'churn'
        else 'active'
        end as status,
	 case 
        when sum(i.total) >= 100 then 'high value'
        when sum(i.total) >= 50 then 'mid value'
        else 'low value'
     end as spending_segment,
     case
		when count(distinct invoice_id) >= 12 AND datediff(max(i.invoice_date), min(i.invoice_date)) > 90 then 'frequent'
		when count(distinct invoice_id) between 6 and 11 then 'occasional'
		else 'rare'
		end as frequency_segment,
    round(avg(i.total) * count(i.invoice_id) * datediff(max(i.invoice_date), min(i.invoice_date)) / 365, 2) AS customer_lifetime_value
from 
	customer c
    inner join 
    invoice i on c.customer_id= i.customer_id
group by c.customer_id,state, c.country;


-- How can you alter the "Albums" table to add a new column named "ReleaseYear" of type INTEGER to store the release year of each album
alter table album 
add column releaseyear integer;
select * from album;
-- some id updated 2017
update album
set releaseyear= 2017
where album_id in(1,3,4,6,7);

-- some id updated 2018
update album
set releaseyear= 2018
where album_id in(2,5,8,9,10);




with purchase_summary as(select 
	c.customer_id,
	c.country,
	sum(il.quantity) as total_tracks,
	sum(i.total) as total_spent
from 
	customer c
	inner join 
    invoice i on c.customer_id = i.customer_id
    inner join 
    invoice_line il on i.invoice_id = il.invoice_id
    group by c.customer_id, c.country)
select 
    country,
    count(distinct customer_id) as number_of_customers,
    round(sum(total_tracks), 2) as total_tracks,
    round(avg(total_tracks), 2) as average_tracks_purchased_per_customer,
    round(sum(total_spent), 2) as total_amount_spent,
    round(avg(total_spent), 2) as average_amount_spent_per_customer
from purchase_summary
group by country
order by average_amount_spent_per_customer desc;



    

    
    
    

	
	
	

	