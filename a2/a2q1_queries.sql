-- CSC 370 - Spring 2018
-- Assignment 2: Queries for Question 1 (imdb)
-- Name: Dylan Dvorachek
-- Student ID: V00863468

-- Place your query for each sub-question in the appropriate position
-- below. Do not modify or remove the '-- Question 1x --' header before
-- each question.


-- Question 1a --

with
    primary_name as (select title_id, name as primary_name from title_names where is_primary = true)
    
select primary_name, year, title_id 
from 
    (select *
    from titles
      natural join
    primary_name
    where year = 1989 and title_type = 'tvSpecial' and length_minutes = 180) as X;

-- Question 1b --

with
    primary_name as (select title_id, name as primary_name from title_names where is_primary = true)

select primary_name, year, length_minutes
from
    (select *
    from titles
      natural join
    primary_name
    where title_type = 'movie' and length_minutes >= 4320) as X
    order by length_minutes desc;

-- Question 1c --

with
    primary_name as (select title_id, name as primary_name from title_names where is_primary = true),

    meryl_movies as
        (select *
        from cast_crew 
          natural join
        people
        where name = 'Meryl Streep')

select primary_name, year, length_minutes
from
    (select * from primary_name natural join meryl_movies) as X
      natural join
    titles
    where title_type = 'movie' and year <= 1985;

-- Question 1d --

with
    primary_name as (select title_id, name as primary_name from title_names where is_primary = true),
    
    noir_m as (select title_id, year, length_minutes from titles natural join title_genres where genre = 'Film-Noir'),
    
    action_m as (select title_id, year, length_minutes from titles natural join title_genres where genre = 'Action')
    
select primary_name, year, length_minutes
from (select * from noir_m natural join action_m) as X_again
  natural join
primary_name
order by primary_name;

-- Question 1e --

with
    lebowski as (select title_id from title_names
                  natural join
                titles
                where is_primary = true and name = 'The Big Lebowski' and title_type = 'movie')

select name
from (lebowski natural join cast_crew) as X
  natural join
people
order by name;

-- Question 1f --

with
    die_hard as 
        (select title_id 
        from title_names
          natural join
        titles
        where is_primary = true and name = 'Die Hard' and title_type = 'movie'),

    directors_writers as (select * from directors natural join die_hard
                            union
                          select * from writers natural join die_hard)
  
select name from directors_writers natural join people order by name;

-- Question 1g --

with
    primary_name as (select title_id, name as primary_name from title_names where is_primary = true),
    
    tom_cruise as
        (select *
         from known_for
           natural join
         people
         where name = 'Tom Cruise')
        
select primary_name, length_minutes
from (select * from tom_cruise natural join titles where title_type = 'movie') as X
  natural join
primary_name
order by primary_name;

-- Question 1h --

with
    primary_name as (select title_id, name as primary_name from title_names where is_primary = true),

    meryl as
        (select title_id
        from cast_crew 
          natural join
        people
        where name = 'Meryl Streep'),
    
    tom as
        (select title_id
        from cast_crew 
          natural join
        people
        where name = 'Tom Hanks'),
    
    meryl_hanks as (select * from Tom natural join Meryl)
    
select primary_name, year, length_minutes
from (select * from meryl_hanks natural join titles where title_type = 'movie') as X
  natural join
primary_name
order by primary_name;

-- Question 1i --

with
    primary_name as (select title_id, name as primary_name from title_names where is_primary = true),

    thrillers as (select * from titles natural join title_genres where genre = 'Thriller' and title_type = 'movie'),
    
    spielberg as (select * from directors natural join people where name = 'Steven Spielberg')

select primary_name, year
from (select * from thrillers natural join spielberg) as X
  natural join
primary_name
order by primary_name;
