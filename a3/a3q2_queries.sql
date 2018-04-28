-- CSC 370 - Spring 2018
-- Assignment 3: Queries for Question 2 (ferries)
-- Name: Dylan Dvorachek
-- Student ID: V00863468

-- Place your query for each sub-question in the appropriate position
-- below. Do not modify or remove the '-- Question 2x --' header before
-- each question.


-- Question 2a --

with
    simul_sailings as (select s1.vessel_name as vessel1, s2.vessel_name as vessel2, s1.route_number
        from sailings as s1
          inner join
        sailings as s2
        on s1.scheduled_departure = s2.scheduled_departure
        and s1.route_number = s2.route_number
        and s1.vessel_name <> s2.vessel_name
        and s1.vessel_name < s2.vessel_name)

select vessel1, vessel2, count(route_number) as num_parings
from simul_sailings
group by vessel1, vessel2
order by num_parings desc;

-- Question 2b --

with
    actual_minutes as (select route_number,
        (extract(epoch from arrival) - extract(epoch from scheduled_departure))/60 as minutes
        from sailings),
        
    averages as (select route_number, avg(minutes) as avg_duration
        from actual_minutes
        group by route_number)

select route_number, nominal_duration, avg_duration
from averages
  natural join
routes
order by route_number;

-- Question 2c --

with
    month_day_late as (select extract(year from scheduled_departure) as year,
        extract(month from scheduled_departure) as month,
        extract(day from scheduled_departure) as day
        from sailings
          natural join
        routes
        where nominal_duration + 5 <= (extract(epoch from arrival) - extract(epoch from scheduled_departure))/60
        and route_number = 1),

    all_dates as (select distinct extract(year from scheduled_departure) as year,
        extract(month from scheduled_departure) as month,
        extract(day from scheduled_departure) as day
        from sailings
          natural join
        routes
        where route_number = 1
        order by year desc, month, day),
        
    month_day_no_late as(select * from all_dates
          except
        select * from month_day_late)

select month, count(day)
from month_day_no_late
group by month
order by month;

-- Question 2d --

with
    total as (select vessel_name, count(scheduled_departure) as total_sailings
        from sailings
        group by vessel_name),
        
    late as (select vessel_name, count(scheduled_departure) as late_sailings
        from sailings
          natural join 
        routes
        where nominal_duration + 5 <= (extract(epoch from arrival) - extract(epoch from scheduled_departure))/60
        group by vessel_name),
        
    combined as (select total.vessel_name, total_sailings, coalesce(late_sailings, 0) as late_sailings
        from total
          left join late
        on total.vessel_name = late.vessel_name)

select vessel_name, total_sailings, late_sailings, late_sailings/total_sailings::float as late_fraction
from combined
order by vessel_name;

-- Question 2e --

with
    all_days as (select route_number, 
        date_trunc('day', scheduled_departure)::date as days
        from sailings
          natural join
        routes),
        
    rankings as (select distinct route_number, days , rank() over(partition by route_number order by days) as f,
            rank() over(partition by route_number order by days desc) as l
        from all_days),
        
    first_days as (select route_number, days-1 as late_day
        from rankings
        where f = 1),
        
    last_days as (select route_number, days+1 as late_day
        from rankings
        where l = 1),

    late as (select route_number,
        date_trunc('day', scheduled_departure)::date as late_day
        from sailings
          natural join
        routes
        where nominal_duration + 5 <= (extract(epoch from arrival) - extract(epoch from scheduled_departure))/60),
        
    routes_late as (select * from first_days union select * from last_days union select * from late),

    routes_late_pairs as (select distinct X.route_number, X.late_day, X.next_late_day
        from (select route_number, late_day, 
            min(late_day) over (partition by route_number
                                order by late_day
                                rows between 1 following and unbounded following) as next_late_day
            from (select distinct * from routes_late) as T1) as X
        where X.late_day < X.next_late_day),
    
    days_between as (select route_number, next_late_day, next_late_day-late_day-1 as days_without_a_late_sailing
        from routes_late_pairs)


select route_number, max(days_without_a_late_sailing) as days_without_a_late_sailing
from days_between
group by route_number
order by route_number;


-- Question 2f --

with
    all_days as (select route_number, 
        date_trunc('day', scheduled_departure)::date as days
        from sailings
          natural join
        routes),
        
    rankings as (select distinct route_number, days , rank() over(partition by route_number order by days) as f,
            rank() over(partition by route_number order by days desc) as l
        from all_days),
        
    first_days as (select route_number, days-1 as late_day
        from rankings
        where f = 1),
        
    last_days as (select route_number, days+1 as late_day
        from rankings
        where l = 1),
        
    late as (select route_number,
        date_trunc('day', scheduled_departure)::date as late_day
        from sailings
          natural join
        routes
        where nominal_duration + 5 <= (extract(epoch from arrival) - extract(epoch from scheduled_departure))/60),
        
    routes_late as (select * from first_days union select * from last_days union select * from late),

    routes_late_pairs as (select distinct X.route_number, X.late_day, X.next_late_day
        from (select route_number, late_day, 
            min(late_day) over (partition by route_number
                                order by late_day
                                rows between 1 following and unbounded following) as next_late_day
            from (select distinct * from routes_late) as T1) as X
        where X.late_day < X.next_late_day),
    
    days_between as (select route_number, late_day, next_late_day, next_late_day-late_day-1 as days_without_a_late_sailing
        from routes_late_pairs),

    consecutive as (select route_number, max(days_without_a_late_sailing) as days_without_a_late_sailing
        from days_between
        group by route_number)

select route_number, late_day+1 as start_day, next_late_day-1 as end_day, days_without_a_late_sailing
from days_between
  natural join
consecutive
where days_between.days_without_a_late_sailing = consecutive.days_without_a_late_sailing
order by route_number;

-- Question 2g --

with
    make_believe as (select vessel_name
        from sailings 
          natural join
        routes
        where 15 <= (extract(epoch from actual_departure) - extract(epoch from scheduled_departure))/60
        and nominal_duration + 5 >= (extract(epoch from arrival) - extract(epoch from scheduled_departure))/60)

select vessel_name, count(vessel_name) as made_up_sailings
from make_believe
group by vessel_name
order by vessel_name;
