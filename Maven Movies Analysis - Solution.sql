/* 
1. My partner and I want to come by each of the stores in person and meet the managers. 
Please send over the managers’ names at each store, with the full address 
of each property (street address, district, city, and country please).  
*/ 


select concat(first_name, ' ', last_name) as name, address, district, city, country from store
join staff
on store.store_id = staff.store_id
join address
on 
address.address_id = staff.address_id
join city on 
address.city_id = city.city_id
join country on city.country_id = country.country_id

	
/*
2.	I would like to get a better understanding of all of the inventory that would come along with the business. 
Please pull together a list of each inventory item you have stocked, including the store_id number, 
the inventory_id, the name of the film, the film’s rating, its rental rate and replacement cost. 
*/

select store_id, inventory_id, title, rating, rental_rate, replacement_cost  from inventory
join film
on inventory.film_id = film.film_id
order by store_id ;

/* 
3.	From the same list of films you just pulled, please roll that data up and provide a summary level overview 
of your inventory. We would like to know how many inventory items you have with each rating at each store. 
*/

select store_id, rating, count(inventory_id) as inventory_count from inventory
join film
on inventory.film_id = film.film_id
group by store_id, rating;


/* 
4. Similarly, we want to understand how diversified the inventory is in terms of replacement cost. We want to 
see how big of a hit it would be if a certain category of film became unpopular at a certain store.
We would like to see the number of films, as well as the average replacement cost, and total replacement cost, 
sliced by store and film category. 
*/ 


select store.store_id, category.name, count(title) as number_of_films,  avg(replacement_cost) as avg_replacement_cost, sum(replacement_cost) as total_replacement_cost from film_category
left join film on film.film_id = film_category.film_id
left join inventory on  inventory.film_id = film.film_id
left join store on inventory.store_id = store.store_id
left join category on category.category_id = film_category.category_id
group by store_id, category.name
order by total_replacement_cost desc
;



/*
5.	We want to make sure you folks have a good handle on who your customers are. Please provide a list 
of all customer names, which store they go to, whether or not they are currently active, 
and their full addresses – street address, city, and country. 
*/


select concat(first_name, ' ', last_name) as name,  store_id, active, address, city, country from customer
left join address on customer.address_id = address.address_id
left join city on address.city_id = city.city_id
left join country on city.country_id = country.country_id


/*
6.	We would like to understand how much your customers are spending with you, and also to know 
who your most valuable customers are. Please pull together a list of customer names, their total 
lifetime rentals, and the sum of all payments you have collected from them. It would be great to 
see this ordered on total lifetime value, with the most valuable customers at the top of the list. 
*/

with cte1 as (select customer_id, sum(amount) as total_payment from payment
group by customer_id),
cte2 as (select  concat(first_name, ' ', last_name) as name , customer.customer_id, COUNT(DISTINCT rental.rental_id) as lifetime_rentals 
from customer 
left join rental on customer.customer_id = rental.customer_id
left join payment on rental.customer_id = payment.customer_id
group by customer.customer_id
)
select name, lifetime_rentals, total_payment from cte1 join cte2 on cte1.customer_id = cte2.customer_id
order by total_payment desc


/*
7. My partner and I would like to get to know your board of advisors and any current investors.
Could you please provide a list of advisor and investor names in one table? 
Could you please note whether they are an investor or an advisor, and for the investors, 
it would be good to include which company they work with. 
*/

select 'investor' as type,
first_name,
last_name,
company_name 
from investor

UNION 

select 'advisor' as type,
first_name,
last_name,
'N/A'
from advisor;

/*
8. We're interested in how well you have covered the most-awarded actors. 
Of all the actors with three types of awards, for what % of them do we carry a film?
And how about for actors with two types of awards? Same questions. 
Finally, how about actors with just one award? 
*/

with cte1 as (SELECT  count(awards) as award_count,   CASE WHEN awards = 'Emmy, Oscar, Tony ' then '3 Awards'
when awards in ('Emmy, Oscar', 'Emmy, Tony', 'Oscar, Tony') then '2 Awards'
else '1 Award'  end
as number_of_awards
from actor_award
left join actor 
on actor_award.actor_id = actor.actor_id
group by 
CASE WHEN awards = 'Emmy, Oscar, Tony ' then '3 Awards'
when awards in ('Emmy, Oscar', 'Emmy, Tony', 'Oscar, Tony') then '2 Awards'
else '1 Award'  end),
cte2 as (select number_of_awards, award_count/sum(award_count) over() * 100 as percentage_of_actors from cte1 group by number_of_awards)
select cte1.number_of_awards, award_count, percentage_of_actors from cte1 join cte2 on cte1.number_of_awards = cte2.number_of_awards