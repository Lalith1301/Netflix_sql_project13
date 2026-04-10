drop table if exists netflix

create Table netflix(
	show_id varchar(10),
	type text,
	title text,
	director text,
	casts text,
	country text,
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(100),
	duration VARCHAR(150),
	listed_in VARCHAR(150),
	description VARCHAR(600)
)

select * from netflix

---- let's start -----


/* Questions

1. Count the number of Movies vs TV Shows available on Netflix
2. Find the most common rating for Movies and TV Shows
3. Find the distribution of content ratings across different countries.
4. List all Movies released in a specific year (e.g., 2020)
5. Identify the top 5 countries with the highest number of content titles
6. Find the longest Movie and the TV Show with the highest number of seasons
7. Retrieve all content added to Netflix in the last 5 years
8. Find all content directed by a specific director (e.g., Rajiv Chilaka)
9. List all TV Shows with more than 5 seasons
10. Count the number of content items in each genre
11. Find the top 5 genres with the highest number of titles
12. Find all content that does not have a listed director
13. Count how many titles a specific actor appeared in over the last 10 years
14. Find the top 10 actors who have appeared in the highest number of titles
15. Find the percentage of content that is Movies vs TV Shows for each country
16. Find all content that was added to Netflix in the same year it was released
17. Identify titles where the release year is more than 10 years older than the year added
18. Calculate the proportion of content added in the last 3 years vs older content

*/

-- 
----------

-- 1. Count the number of Movies vs TV Shows available on Netflix

Select type , count(*) as number_of_shows
from netflix
group by type

-- 2. Find the most common rating for Movies and TV Shows

SELECT 
    type,
    rating,
    COUNT(*) AS total_count
FROM netflix
WHERE rating IS NOT NULL
GROUP BY type, rating
ORDER BY type, total_count DESC;

-- 3. Find the distribution of content ratings across different countries.

SELECT 
    TRIM(unnest(string_to_array(country, ','))) AS new_country,
    rating,COUNT(*) AS total_titles
FROM netflix
WHERE country IS NOT NULL
  AND country <> ' '
  AND rating IS NOT NULL
GROUP BY new_country , rating
ORDER BY new_country, total_titles DESC;

-- 4. List all Movies released in a specific year (e.g., 2020)

SELECT *
FROM netflix
WHERE type = 'Movie'
  AND release_year = 2020;

-- 5. Identify the top 5 countries with the highest number of content titles

SELECT 
    TRIM(unnest(string_to_array(country, ','))) AS new_country,
    COUNT(*) AS total_titles
FROM netflix
WHERE country IS NOT NULL
GROUP BY new_country
ORDER BY total_titles DESC
LIMIT 5;

-- 6. Find the longest Movie and the TV Show with the highest number of seasons

-- Movie --
SELECT 
    title,
    duration as minutes,
	release_year
FROM netflix
WHERE type = 'Movie'
  AND duration IS NOT NULL
ORDER BY minutes DESC
LIMIT 10;

-- Seasons --

SELECT 
    title,
    duration AS seasons
FROM netflix
WHERE type = 'TV Show'
  AND duration IS NOT NULL
ORDER BY seasons DESC
LIMIT 10;

------

WITH Longest_Movie AS (
    SELECT title, type, duration
    FROM netflix
    WHERE type = 'Movie' 
      AND duration IS NOT NULL  
    ORDER BY CAST(SPLIT_PART(duration, ' ', 1) AS INT) DESC
    LIMIT 1
),
Most_Seasons AS (
    SELECT title, type, duration
    FROM netflix
    WHERE type = 'TV Show' 
      AND duration IS NOT NULL  
    ORDER BY CAST(SPLIT_PART(duration, ' ', 1) AS INT) DESC
    LIMIT 1
)

SELECT * FROM Longest_Movie
UNION ALL
SELECT * FROM Most_Seasons;


-- 7. Retrieve all content added to Netflix in the last 5 years

SELECT * 
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

-- Step 1: Convert string to Date
-- Step 2: Compare to (Current Date - 5 Years)

--- 8. Find all content directed by a specific director (e.g., Rajiv Chilaka)

"Rajiv Chilaka"
SELECT *
FROM netflix
WHERE director = 'Rajiv Chilaka';

"S.S. Rajamouli"
SELECT *
FROM netflix
WHERE director = 'S.S. Rajamouli';

"Clint Eastwood"
SELECT *
FROM netflix
WHERE director = 'Clint Eastwood';

SELECT director , count(*) as director_movies
FROM netflix
WHERE director is not null
group by director
order by director_movies desc

-- 9.List all TV Shows with more than 5 seasons

SELECT 
    title,
    duration
FROM netflix
WHERE type = 'TV Show'
  AND CAST(SPLIT_PART(duration, ' ', 1) AS INT) > 5;

-- 10. Count the number of content items in each genre

WITH genre_split AS (
    SELECT 
        TRIM(unnest(string_to_array(listed_in, ','))) AS genre
    FROM netflix
)

SELECT 
    genre,
    COUNT(*) AS total_titles
FROM genre_split
WHERE genre <> ''
GROUP BY genre
ORDER BY total_titles DESC;
ORDER BY total_titles DESC;

-- 11. Find the top 5 genres with the highest number of titles

WITH genre_split AS (
    SELECT 
        TRIM(unnest(string_to_array(listed_in, ','))) AS genre
    FROM netflix
)

SELECT 
    genre,
    COUNT(*) AS total_titles
FROM genre_split
WHERE genre <> ''
GROUP BY genre
ORDER BY total_titles DESC
LIMIT 5;

-- 12. Find all content that does not have a listed director
select * from netflix
where director is null

-- 13. Count how many titles a specific actor appeared in over the last 10 years

WITH cast_split AS (
    SELECT 
        release_year,
        TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) AS cast_member
    FROM netflix
)

SELECT 
    cast_member,
    COUNT(*) AS total_titles
FROM cast_split
WHERE cast_member IS NOT NULL
  AND cast_member <> ''
  AND release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 10
GROUP BY cast_member
ORDER BY total_titles DESC;

-- 14. Find the top 10 actors who have appeared in the highest number of titles


WITH cast_split AS (
    SELECT 
        release_year,
        TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) AS cast_member
    FROM netflix
)

SELECT 
    cast_member,
    COUNT(*) AS total_titles
FROM cast_split
WHERE cast_member IS NOT NULL
  AND cast_member <> ''
  AND release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 10
GROUP BY cast_member
ORDER BY total_titles DESC
limit 10;

-- 15. Find the percentage of content that is Movies vs TV Shows for each country

WITH country_split AS (
    SELECT 
        TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS new_country,
        type
    FROM netflix
    WHERE country IS NOT NULL
)

SELECT 
    new_country,
    type,
    COUNT(*) AS total_titles,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY new_country),
        2
    ) AS percentage
FROM country_split
WHERE new_country <> ''
GROUP BY new_country, type
ORDER BY new_country, percentage DESC;