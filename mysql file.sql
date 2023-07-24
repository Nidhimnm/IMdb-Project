use imdb;
Segment 1: Database - Tables, Columns, Relationships  
  -Q1	What are the different tables in the database and how are they connected to each other in the database?  
       The different tables in the database are,movie,role_mapping.director_mpping,names,genre,ratings.
           a.The movie table has a primary key of id which is connected to the movie_id foreign key in the genre, role_mapping, and director_mapping tables.
           b.The genre table has a primary key of genre which is connected to the genre foreign key in the role_mapping table.
           c.The ratings table has a primary key of movie_id which is connected to the movie_id foreign key in the role_mapping table.
           d.The ratings table has a primary key of movie_id which is connected to the movie_id foreign key in the director_mapping table.
           e.The names table has a primary key of id which is connected to the name_id foreign key in the role_mapping, and director_mapping tables.
-Q2	What are the different tables in the database and how are they connected to each other in the database?
-	Find the total number of rows in each table of the schema.
      SELECT COUNT(*) FROM imdb.movie; -- 7997
     select count(*) from imdb.genre; -- 14662
     select count(*) from imdb.ratings; -- 7997
     select count(*) from imdb.role_mapping; -- 15615
     select count(*) from imdb.names; -- 25735
     
     
--Q3.Identify which columns in the movie table have null values.
     SELECT 
		SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS ID_nulls, -- 0
		SUM(CASE WHEN title IS NULL THEN 1 ELSE 0 END) AS title_nulls, -- 0
		SUM(CASE WHEN year IS NULL THEN 1 ELSE 0 END) AS year_nulls, -- 0
		SUM(CASE WHEN date_published IS NULL THEN 1 ELSE 0 END) AS date_published_nulls, -- 0
		SUM(CASE WHEN duration IS NULL THEN 1 ELSE 0 END) AS duration_nulls, -- 0
		SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS country_nulls, -- 20
		SUM(CASE WHEN worlwide_gross_income IS NULL THEN 1 ELSE 0 END) AS worlwide_gross_income_nulls, -- 3724
		SUM(CASE WHEN languages IS NULL THEN 1 ELSE 0 END) AS languages_nulls, -- 194
		SUM(CASE WHEN production_company IS NULL THEN 1 ELSE 0 END) AS production_company_nulls -- 528

FROM movie;
     
     
     
     Segment 2: Movie Release Trends
---Q1	Determine the total number of movies released each year and analyse the month-wise trend.
   -- Total number of movies released each year
SELECT year, COUNT(id) as number_of_movies
FROM movie
GROUP BY year
ORDER BY year; 
 -
-- Month-wise trend of movie releases
SELECT MONTH(date_published) AS month_num, COUNT(id) AS number_of_movies 
FROM movie
GROUP BY MONTH(date_published)
ORDER BY MONTH(date_published);  


 -- In march highest number of movies got released
-Q2	Calculate the number of movies produced in the USA or India in the year 2019.
SELECT COUNT(*) AS total_movies
FROM movie
WHERE (country = 'USA' OR country = 'India') AND YEAR(date_published) = 2019;   -- 887  

Segment 3: Production Statistics and Genre Analysis
--Q1.Retrieve the unique list of genres present in the dataset.  
   SELECT DISTINCT genre from genre;
--Q2.Identify the genre with the highest number of movies produced overall. 
SELECT genre, COUNT(*) AS total_movies
FROM genre
GROUP BY genre
ORDER BY total_movies DESC
limit 1;

--Q3.Determine the count of movies that belong to only one genre. 
    SELECT movie_id,count(distinct(genre)) from genre 
       group by movie_id
        having count(distinct(genre)) <2;


--Q4.Calculate the average duration of movies in each genre. 
  select  avg(duration ) ,genre from movie inner join genre
         where movie.id=genre.movie_id
         group by genre;
 
-Q5.Find the rank of the 'thriller' genre among all genres in terms of the number of movies produced?  
       with genre_movie_count as ( select  genre,count(distinct(movie_id)) as movie_count from movie inner join genre
         on movie.id=genre.movie_id
         group by genre
         order by  movie_count desc),
         genre_rnk as (select genre, rank() over(order by movie_count desc) as rnk from genre_movie_count)
         select rnk from genre_rnk where genre = 'Thriller';

Segment 4: Ratings Analysis and Crew Members
--Q1.Retrieve the minimum and maximum values in each column of the ratings table (except movie_id).  
    SELECT MIN(avg_rating) AS min_avg_rating, MAX(avg_rating) AS max_avg_rating,
       MIN(total_votes) AS min_total_votes, MAX(total_votes) AS max_total_votes,
       MIN(median_rating) AS min_median_rating, MAX(median_rating) AS max_median_rating
FROM ratings;

--Q2.Identify the top 10 movies based on average rating.  
select movie.title,ratings.avg_rating
from movie
join ratings
on movie.id=ratings.movie_id
order by ratings.avg_rating desc
limit 10;

-	Summarise the ratings table based on movie counts by median ratings. 
 select median_rating,count(*) as movie_count from ratings
             group by median_rating
             order by median_rating desc;

--Q3.Identify the production house that has produced the most number of hit movies (average rating > 8).  
 with cte as (select  movie_id, production_company from ratings inner join movie on movie.id=ratings.movie_id where avg_rating>8)
          select count(distinct movie_id) as movie_count,production_company from cte group by production_company order by movie_count desc limit 10;

-Q4.Determine the number of movies released in each genre during March 2017 in the USA with more than 1,000 votes.  

   select count(distinct genre.movie_id) as movie_count,
                  genre 
			from ratings join movie on movie.id=ratings.movie_id
			     join genre on movie.id=genre.movie_id
             where country='USA' AND  total_votes>1000  and month(date_published) = 3 and  year(date_published)=2017
           	group by genre;


-Q5.Retrieve movies of each genre starting with the word 'The' and having an average rating > 8.    
 select title from
                  movie join ratings on movie.id=ratings.movie_id
			     join genre on ratings.movie_id=genre.movie_id
                 where title like "The%" and avg_rating > 8; 

Segment 5: Crew Analysis
-Q1.Identify the columns in the names table that have null values.  
SELECT 
		SUM(CASE WHEN name IS NULL THEN 1 ELSE 0 END) AS name_nulls, -- 0
		SUM(CASE WHEN height IS NULL THEN 1 ELSE 0 END) AS height_nulls, -- 17335
		SUM(CASE WHEN date_of_birth IS NULL THEN 1 ELSE 0 END) AS date_of_birth_nulls, -- 13431
		SUM(CASE WHEN known_for_movies IS NULL THEN 1 ELSE 0 END) AS known_for_movies_nulls -- 15226
		
FROM names;

---Q2.Determine the top three directors in the top three genres with movies having an average rating > 8.   
      WITH top_genres AS (
    SELECT genre, COUNT(*) as count
    FROM genre
    JOIN ratings ON genre.movie_id = ratings.movie_id
    WHERE ratings.avg_rating > 8
    GROUP BY genre
    ORDER BY count DESC
    LIMIT 3
),
top_directors AS (
    SELECT name_id, COUNT(*) as count
    FROM director_mapping
    JOIN ratings ON director_mapping.movie_id = ratings.movie_id
    WHERE ratings.avg_rating > 8
    GROUP BY name_id
    ORDER BY count DESC
    LIMIT 3
)
SELECT names.name, top_genres.genre, top_directors.count
FROM names
JOIN top_directors ON names.id = top_directors.name_id
JOIN director_mapping ON names.id = director_mapping.name_id
JOIN genre ON director_mapping.movie_id = genre.movie_id
JOIN top_genres ON genre.genre = top_genres.genre limit 3;
   
--Q3.Find the top two actors whose movies have a median rating >= 8.  
SELECT DISTINCT name AS actor_name, COUNT(r.movie_id) AS movie_count
FROM ratings AS r
INNER JOIN role_mapping AS rm
ON rm.movie_id = r.movie_id
INNER JOIN names AS n
ON rm.name_id = n.id
WHERE median_rating >= 8 AND category = 'actor'
GROUP BY name
ORDER BY movie_count DESC
LIMIT 2;

---Q4.Identify the top three production houses based on the number of votes received by their movies.  
 SELECT movie.production_company, SUM(ratings.total_votes) as total_votes
FROM movie
JOIN ratings ON movie.id = ratings.movie_id
GROUP BY movie.production_company
ORDER BY total_votes DESC
LIMIT 3;

-Q5. Rank actors based on their average ratings in Indian movies released in India. 
SELECT names.name, AVG(ratings.avg_rating) as avg_rating
FROM names
JOIN role_mapping ON names.id = role_mapping.name_id
JOIN movie ON role_mapping.movie_id = movie.id
JOIN ratings ON movie.id = ratings.movie_id
WHERE role_mapping.category = 'actor' AND movie.country = 'India'
GROUP BY names.name
ORDER BY avg_rating DESC;

-Q6.Identify the top five actresses in Hindi movies released in India based on their average ratings.  

SELECT names.name, AVG(ratings.avg_rating) as avg_rating
FROM names
JOIN role_mapping ON names.id = role_mapping.name_id
JOIN movie ON role_mapping.movie_id = movie.id
JOIN ratings ON movie.id = ratings.movie_id
WHERE role_mapping.category = 'actress' AND movie.country = 'India' AND movie.languages LIKE '%Hindi%'
GROUP BY names.name
ORDER BY avg_rating DESC
LImit 5;
   
Segment 6: Broader Understanding of Data
-	Q1.Classify thriller movies based on average ratings into different categories.  
SELECT
  CASE
    WHEN avg_rating >= 9 THEN 'Excellent'
    WHEN avg_rating >= 8 THEN 'Very Good'
    WHEN avg_rating >= 7 THEN 'Good'
    ELSE 'Average or Below'
  END AS rating_category,
  COUNT(*) AS movie_count
FROM movie m
JOIN genre g ON m.id = g.movie_id
JOIN ratings r ON m.id = r.movie_id
WHERE g.genre = 'thriller'
GROUP BY rating_category;

-Q2	analyse the genre-wise running total and moving average of the average movie duration.   
WITH genre_avg_duration AS (
  SELECT g.genre, AVG(m.duration) AS avg_duration
  FROM genre g
  JOIN movie m ON g.movie_id = m.id
  GROUP BY g.genre
  ORDER BY g.genre
),
genre_running_total AS (
  SELECT genre, avg_duration,
    SUM(avg_duration) OVER (PARTITION BY genre ORDER BY genre) AS running_total
  FROM genre_avg_duration
),
genre_moving_average AS (
  SELECT genre, avg_duration,
    AVG(avg_duration) OVER (PARTITION BY genre ORDER BY genre ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS moving_average
  FROM genre_avg_duration
)
SELECT r.genre, r.avg_duration, r.running_total, m.moving_average
FROM genre_running_total r
JOIN genre_moving_average m ON r.genre = m.genre;


-	03.Identify the five highest-grossing movies of each year that belong to the top three genres.  
WITH top_3_genre AS
( 	
	SELECT genre, COUNT(movie_id) AS number_of_movies
    FROM genre AS g
    INNER JOIN movie AS m
    ON g.movie_id = m.id
    GROUP BY genre
    ORDER BY COUNT(movie_id) DESC
    LIMIT 3
),

top_5 AS
(
	SELECT genre,
			year,
			title AS movie_name,
			worlwide_gross_income,
			DENSE_RANK() OVER(PARTITION BY year ORDER BY worlwide_gross_income DESC) AS movie_rank
        
	FROM movie AS m 
    INNER JOIN genre AS g 
    ON m.id= g.movie_id
	WHERE genre IN (SELECT genre FROM top_3_genre)
)

SELECT *
FROM top_5
WHERE movie_rank<=5;


-	04.Determine the top two production houses that have produced the highest number of hits among multilingual movies.  
SELECT production_company,
		COUNT(m.id) AS movie_count,
        ROW_NUMBER() OVER(ORDER BY count(id) DESC) AS prod_comp_rank
FROM movie AS m 
INNER JOIN ratings AS r 
ON m.id=r.movie_id
WHERE median_rating>=8 AND production_company IS NOT NULL AND POSITION(',' IN languages)>0
GROUP BY production_company
LIMIT 2;
-	05.Identify the top three actresses based on the number of Super Hit movies (average rating > 8) in the drama genre.  
 SELECT n.name AS actress, COUNT(*) AS super_hit_count
FROM names n
JOIN role_mapping rm ON n.id = rm.name_id
JOIN movie m ON rm.movie_id = m.id
JOIN genre g ON m.id = g.movie_id
JOIN ratings r ON m.id = r.movie_id
WHERE g.genre = 'drama' AND r.avg_rating > 8 AND rm.category = 'actress'
GROUP BY n.name
ORDER BY super_hit_count DESC
LIMIT 3;

-06.Retrieve details for the top nine directors based on the number of movies, including average inter-movie duration, ratings, and more.
SELECT n.name AS director, COUNT(DISTINCT m.id) AS movie_count, 
       AVG(m.duration) AS avg_duration, AVG(r.avg_rating) AS avg_rating,
       MIN(r.avg_rating) AS min_rating, MAX(r.avg_rating) AS max_rating,
       SUM(r.total_votes) AS total_votes
FROM names n
JOIN director_mapping dm ON n.id = dm.name_id
JOIN movie m ON dm.movie_id = m.id
JOIN ratings r ON m.id = r.movie_id
GROUP BY n.name
ORDER BY movie_count DESC
LIMIT 9;  

Segment 7: Recommendations
-	Based on the analysis, provide recommendations for the types of content Bolly movies should focus on producing.  
   1.A total of 1078 movies were produced in the year 2019 in ‘Drama’ genre. Therefore, RSVP Movies should focus on ‘Drama’ genre for their next project.
2.Approximately, the future project could have an average duration of 107 mins.
3.From the dataset, we can predict that Dream Warrior Pictures (Ranked 1st) or National Theater Live (Ranked 2nd) or both could be their next project’s  production company.
4.Due to higher average rating, James Mangold can be hired as the director for their next project.
5. Bases on the median rating, Mammootty (ranked 1st) or Mohanlal (Ranked 2nd) can be hired as the actor for their next project.
6.Based on the total votes received and average rating, Taapsee Pannu can be chosen as the actress for their next project.
7.Based on the total votes and also for the regional feel, Vijay Sethupathi can be hired as the additional actor for their next project.
8.As a global partner, Marvel studios (Ranked 1st), Twentieth century Fox (Ranked 2nd) or Warner Bros can be chosen as the number of votes received is comparatively higher than other production houses.

   
  

The below questions are not a part of the problem statement but should be included after the their completion to test their understanding:

-	01.Determine the average duration of movies released by Bolly Movies compared to the industry average. 
       WITH bolly_movies_avg AS (
    SELECT AVG(duration) AS avg_duration
    FROM movie
    WHERE production_company = 'Bolly Movies'
),
industry_avg AS (
    SELECT AVG(duration) AS avg_duration
    FROM movie
)
SELECT bolly_movies_avg.avg_duration AS bolly_movies_avg_duration, industry_avg.avg_duration AS industry_avg_duration
FROM bolly_movies_avg, industry_avg;
-	02.Analyse the correlation between the number of votes and the average rating for movies produced by Bolly Movies. 
SELECT
    (COUNT(*)*SUM(x*y)-SUM(x)*SUM(y)) /
    (SQRT(COUNT(*)*SUM(x*x)-SUM(x)*SUM(x)) * SQRT(COUNT(*)*SUM(y*y)-SUM(y)*SUM(y))) AS correlation
FROM (
    SELECT r.total_votes AS x, r.avg_rating AS y
    FROM movie m
    JOIN ratings r ON m.id = r.movie_id
    WHERE m.production_company = 'Bolly Movies'
) t;
-	03.Find the production house that has consistently produced movies with high ratings over the past three years.  
   WITH recent_movies AS (
    SELECT m.production_company, AVG(r.avg_rating) AS avg_rating
    FROM movie m
    JOIN ratings r ON m.id = r.movie_id
    WHERE m.year >= YEAR(CURDATE()) - 3
    GROUP BY m.production_company
)
SELECT production_company
FROM recent_movies
WHERE avg_rating = (SELECT MAX(avg_rating) FROM recent_movies);
-	04.Identify the top three directors who have successfully delivered commercially successful movies with high ratings.
      WITH director_success AS (
    SELECT n.name, COUNT(DISTINCT m.id) AS movie_count, AVG(r.avg_rating) AS avg_rating, SUM(m.worlwide_gross_income) AS total_gross_income
    FROM names n
    JOIN director_mapping dm ON n.id = dm.name_id
    JOIN movie m ON dm.movie_id = m.id
    JOIN ratings r ON m.id = r.movie_id
    GROUP BY n.name
)
SELECT name
FROM director_success
ORDER BY total_gross_income DESC, avg_rating DESC, movie_count DESC
LIMIT 3;






  



   
     

