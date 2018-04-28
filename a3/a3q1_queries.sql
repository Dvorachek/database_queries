-- CSC 370 - Spring 2018
-- Assignment 3: Queries for Question 1 (imdb)
-- Name: Dylan Dvorachek
-- Student ID: V00863468

-- Place your query for each sub-question in the appropriate position
-- below. Do not modify or remove the '-- Question 1x --' header before
-- each question.


-- Question 1a --

with
    primary_name as (select title_id, name as primary_name from title_names where is_primary = true),
    
    movies as (select *
        from titles
          natural join
        ratings
        where year >= 2000 and year <= 2017 and title_type = 'movie' and votes >= 10000),

    top_rated as (select title_id, year, votes, rating
        from movies
          natural join 
        (select year, max(rating) as rating
        from movies
        group by year) as X
        where year = X.year and rating = X.rating)

select primary_name, year, rating, votes
from primary_name
  natural join
top_rated
order by year;

-- Question 1b --

with 
    series_count as (select series_id as title_id, count(title_id) as episode_count
        from series_episodes
        group by series_id
        having count(title_id) >= 6000),
        
    primary_name as (select title_id, name 
        from title_names  
        where is_primary = true)

select name as series_name, episode_count
from series_count
  natural join
primary_name
order by episode_count desc;
