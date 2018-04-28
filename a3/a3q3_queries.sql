-- CSC 370 - Spring 2018
-- Assignment 3: Queries for Question 3 (vwsn_1year)
-- Name: Dylan Dvorachek
-- Student ID: V00863468

-- Place your query for each sub-question in the appropriate position
-- below. Do not modify or remove the '-- Question 3x --' header before
-- each question.


-- Question 3a --

with
    ranking as (select station_id, observation_time, temperature,
        rank() over (order by temperature desc)
        from observations)
        
select station_id, name, temperature, observation_time
from ranking
  inner join
stations
on ranking.station_id = stations.id
where rank = 1;

-- Question 3b --

with
    max_temp as (select station_id, max(temperature) as max_temperature
        from observations
        where station_id between 1 and 10
        group by station_id)
        
select max_temp.station_id, stations.name, max_temperature, observation_time 
from max_temp
  inner join
observations
on max_temp.max_temperature = observations.temperature
and max_temp.station_id = observations.station_id
  inner join
stations
on max_temp.station_id = stations.id;

-- Question 3c --

with
    in_date as (select distinct station_id
        from observations
        where extract(month from observation_time) = 6
        and extract(year from observation_time) = 2017),

    not_in_date as (select station_id from observations
          except        
        select * from in_date)

select station_id, name
from not_in_date
  inner join
stations
on not_in_date.station_id = stations.id;

-- Question 3d --

with
    daily_avg as (select date_trunc('day', observation_time)::date as day, avg(temperature) as temp
        from observations
        group by day),
        
    ranking as (select date_trunc('month', day)::date as month,
        temp,
        rank() over (partition by extract(month from day)::int order by temp desc) as hot,
        rank() over (partition by extract(month from day)::int order by temp) as cold
        from daily_avg),
        
    top_hot as (select month, hot, temp
        from ranking
        where hot <= 10),
        
    avg_hot as(select month, avg(temp) as hottest10_average
        from top_hot
        group by month),
    
    top_cold as (select month, cold, temp
        from ranking
        where cold <= 10),
        
    avg_cold as(select month, avg(temp) as coolest10_average
        from top_cold
        group by month)

select distinct extract(year from ranking.month)::int as year,
    extract(month from ranking.month)::int as month,
    hottest10_average, coolest10_average
from ranking
  inner join
avg_hot
on ranking.month = avg_hot.month
  inner join
avg_cold
on avg_hot.month = avg_cold.month
order by year, month;

-- Question 3e --

with
    daily_avg as (select date_trunc('day', observation_time)::date as day, avg(temperature) as temp
        from observations
        group by day),
    
    min_count as (select day, temp,
            count(temp) over(rows between 28 preceding and 1 preceding) as num_prev,
            min(temp) over(rows between 28 preceding and current row) as cur_min
        from daily_avg)

select extract(year from day)::int as year,
    extract(month from day)::int as month,
    extract(day from day)::int as day
from min_count
where num_prev = 28
and temp = cur_min;
