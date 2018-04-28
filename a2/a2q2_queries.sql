-- CSC 370 - Spring 2018
-- Assignment 2: Queries for Question 2 (ferries)
-- Name: Dylan Dvorachek
-- Student ID: V00863468

-- Place your query for each sub-question in the appropriate position
-- below. Do not modify or remove the '-- Question 2x --' header before
-- each question.


-- Question 2a --

select distinct vessel_name 
from sailings 
where route_number = 1
order by vessel_name;

-- Question 2b --

select vessel_name, count(vessel_name) 
from sailings 
group by vessel_name 
order by vessel_name;

-- Question 2c --

select vessel_name, count(distinct route_number) as num_routes 
from sailings 
group by vessel_name 
having count(distinct route_number) >= 2;

-- Question 2d --

with
    vessels as (select route_number, vessel_name, year_built
                from (select distinct vessel_name, route_number from sailings) as X
                  natural join
                fleet)

select route_number, vessel_name, year_built
from (select route_number, min(year_built) as year_built
     from vessels
     group by route_number) as X
  natural join
vessels
order by route_number;

-- Question 2e --

with
    destination as (select distinct destination_port
                    from sailings
                    where vessel_name = 'Queen of New Westminster'),
    
    source as (select distinct source_port
               from sailings
               where vessel_name = 'Queen of New Westminster')

select distinct vessel_name
from sailings
  natural join
destination
  union
select distinct vessel_name
from sailings
  natural join
source
order by vessel_name;




-- Mar2_date_time_queries.sql
--
-- Examples of various queries which use date/time functions
-- in PostgreSQL. See the page below for details on the date/time
-- functions.
--
-- https://www.postgresql.org/docs/9.5/static/functions-datetime.html 
--
-- In the lecture, these queries were run on the ferries_1month database
--
-- B. Bird - 03/02/2018

-- Query 1: Select all sailings of the vessel 'Queen of New Westminster'
-- from January 4th. Note that since we're using ferries_1month, no more
-- than one January 4th will be in the dataset (in general, you could add an
-- extra part to the WHERE to restrict by year.

select * 
	from sailings 
	where vessel_name = 'Queen of New Westminster'
	and extract(month from scheduled_departure) = 1
	and extract(day from scheduled_departure) = 4;


-- Query 2: Select the actual departure hour and minute of 
-- each of the sailings above.

select extract(hour from actual_departure) as departure_hour, extract(minute from actual_departure) as departure_minute
	from sailings 
	where vessel_name = 'Queen of New Westminster'
	and extract(month from scheduled_departure) = 1
	and extract(day from scheduled_departure) = 4;


-- Query 3: Find the duration (difference between actual departure and arrival)
-- of each of the sailings above.
-- NOTE: The "duration" is defined differently for assignment 3 
-- (as difference between scheduled departure and arrival)

-- Using "epoch" with extract() will return the timestamp converted to an integer
-- value (the number of seconds since the Unix epoch). These epoch time values can
-- be used to determine the difference in seconds (which can be divided by 60 to 
-- produce a difference in minutes).

select scheduled_departure, actual_departure, arrival, 
	  (extract(epoch from arrival) - extract(epoch from actual_departure))/60 as duration_minutes
	from sailings 
	where vessel_name = 'Queen of New Westminster'
	and extract(month from scheduled_departure) = 1
	and extract(day from scheduled_departure) = 4;

-- Query 4: Select all dates (year/month/day) on which the vessel 
-- 'Queen of New Westminster' had any sailings at all. The date column should be a 
-- single date object (not three separate columns)

-- Version 1: Extract the day/month/year individually, then pass the result into 
-- make_date. Notice the '::int' notation, which is a typecast.

select distinct make_date( extract(year from scheduled_departure)::int, 
						   extract(month from scheduled_departure)::int, 
						   extract(day from scheduled_departure)::int) as sailing_date
	from sailings
	where vessel_name = 'Queen of New Westminster';

-- Version 2: Use the date_trunc function to truncate the scheduled_departure column to
-- the day level (you should experiment with truncating to hour or minute). If the 
-- '::date' cast is not used on the result of date_trunc, the result will be a timestamp
-- (date and time) instead of just a date.
select distinct date_trunc('day',scheduled_departure)::date as sailing_date
	from sailings
	where vessel_name = 'Queen of New Westminster';


-- Query 5: For each day on which the vessel 'Queen of New Westminster' had any sailings, 
-- list the total number of sailings. (This can be done using either of the above queries
-- as a base, and can be done with or without a nested query, but it's a bit messy without
-- a nested query).

select sailing_date, count(*) as total_sailings
	from
		(select date_trunc('day',scheduled_departure)::date as sailing_date
			from sailings
			where vessel_name = 'Queen of New Westminster') as T1
	group by sailing_date
	order by sailing_date;


-- Query 6: For each of the days that the vessel 'Queen of New Westminster' had a sailing,
-- find the date of the next day on which that vessel had any sailings.

-- Version 1: A crafty join
with 
	sailing_days as (select date_trunc('day',scheduled_departure)::date as sailing_date
			from sailings
			where vessel_name = 'Queen of New Westminster')
select S1.sailing_date as sailing_date,
	   min(S2.sailing_date) as next_sailing_date
   from
       sailing_days as S1
   	 inner join
   	   sailing_days as S2
   	 on S1.sailing_date < S2.sailing_date
   group by S1.sailing_date
   order by S1.sailing_date;
   

-- Version 2: Window functions (there are a variety of clever ways to accomplish this)
-- (Notice that a row is added at the end with a NULL next_sailing_date)
with 
	sailing_days as (select date_trunc('day',scheduled_departure)::date as sailing_date
			from sailings
			where vessel_name = 'Queen of New Westminster')
select distinct sailing_date,
	   min(sailing_date) over (order by sailing_date 
							   rows between 1 following and unbounded following) as next_sailing_date	   
   from
       (select distinct * from sailing_days) as T1 --Important to eliminate duplicates before using the window function
   order by sailing_date;
   
-- Query 7: Determine the maximum difference in days between the dates determined above (that is,
-- the maximum number of days without a sailing of the Queen of New Westminster).
-- Note that when two date objects are subtracted, the result is an integer (the number of days between the two dates)
with 
	sailing_days as (select date_trunc('day',scheduled_departure)::date as sailing_date
			from sailings
			where vessel_name = 'Queen of New Westminster'),
	sailing_day_pairs as (
		select distinct sailing_date,
			   min(sailing_date) over (order by sailing_date 
									   rows between 1 following and unbounded following) as next_sailing_date	   
		   from
		       (select distinct * from sailing_days) as T1 --Important to eliminate duplicates before using the window function
		   order by sailing_date),
	days_between_sailings as (
		select sailing_date, next_sailing_date, next_sailing_date-sailing_date-1 as days_without_a_sailing
			from sailing_day_pairs)
select max(days_without_a_sailing) from days_between_sailings;