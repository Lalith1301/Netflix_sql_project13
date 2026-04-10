# **NetFlix Movies and TV Shows Data Analysis using SQL** 

<img src="https://github.com/Lalith1301/Netflix_sql_project13/blob/ea910ec8fac085ee03fdb848eb006f1bd2d10458/115480-2560x1440-desktop-hd-netflix-wallpaper-photo.jpg" width="100%" alt="Netflix Logo">



##  Overview

This project focuses on analyzing Netflix’s content library using SQL to uncover meaningful patterns and insights. Instead of just querying data, the goal is to explore how content is distributed across countries, genres, ratings, and time.

The analysis involves handling real-world data challenges such as multi-valued columns (e.g., countries, genres, cast), missing values, and text-based fields. By transforming and querying the dataset effectively, this project highlights practical SQL skills used in data analysis.

Overall, this project demonstrates how raw data can be converted into useful insights that help understand content trends, audience targeting, and platform growth.

---

##  Objectives
- Understand content distribution across countries
- Analyze genre popularity
- Identify top actors and directors
- Compare Movies vs TV Shows
- Perform time-based analysis

---

## Data set
-  Dataset link : [Netflix Dataset](https://www.kaggle.com/datasets/algozee/netflix-content-analysis)


---

## Table Structure
```SQL
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


```

---

##  Key SQL Concepts Used
- GROUP BY & Aggregations
- Window Functions
- Common Table Expressions (CTEs)
- String Functions (SPLIT_PART, STRING_TO_ARRAY, UNNEST)
- Date Functions
- Data Cleaning Techniques

---

## Business Problems and Solutions

### 1. Count the number of Movies vs TV Shows

```SQL
Select type , count(*) as number_of_shows
from netflix
group by type

```

### 2. Find the most common rating for Movies and TV Shows
```SQL

SELECT 
    type,
    rating,
    COUNT(*) AS total_count
FROM netflix
WHERE rating IS NOT NULL
GROUP BY type, rating
ORDER BY type, total_count DESC;


```

### 3. Find the distribution of content ratings across different countries.

```SQL


SELECT 
    TRIM(unnest(string_to_array(country, ','))) AS new_country,
    rating,COUNT(*) AS total_titles
FROM netflix
WHERE country IS NOT NULL
  AND country <> ' '
  AND rating IS NOT NULL
GROUP BY new_country , rating
ORDER BY new_country, total_titles DESC;

```

### 4. List all Movies released in a specific year (e.g., 2020)

```SQL

SELECT *
FROM netflix
WHERE type = 'Movie'
  AND release_year = 2020;


```

### 5. Identify the top 5 countries with the highest number of content titles

```SQL
SELECT 
    TRIM(unnest(string_to_array(country, ','))) AS new_country,
    COUNT(*) AS total_titles
FROM netflix
WHERE country IS NOT NULL
GROUP BY new_country
ORDER BY total_titles DESC
LIMIT 5;

```

### 6. Find the longest Movie and the TV Show with the highest number of seasons

```SQL
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

```

### 7. Retrieve all content added to Netflix in the last 5 years

```SQL
SELECT * 
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';


```

###  8. Find all content directed by a specific director (e.g., Rajiv Chilaka)

```SQL
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

```

### 9.List all TV Shows with more than 5 seasons

```SQL
SELECT 
    title,
    duration
FROM netflix
WHERE type = 'TV Show'
  AND CAST(SPLIT_PART(duration, ' ', 1) AS INT) > 5;


```

### 10. Count the number of content items in each genre

```SQL
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


```

### 11. Find the top 5 genres with the highest number of titles

```SQL
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

```

###  12. Find all content that does not have a listed director

```SQL
select * from netflix
where director is null

```

### 13. Count how many titles a specific actor appeared in over the last 10 years

```SQL
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

```

### 14. Find the top 10 actors who have appeared in the highest number of titles
```SQL

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


```

### 15. Find the percentage of content that is Movies vs TV Shows for each country

```SQL
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
```


##  Insights

- Netflix catalog is dominated by Movies over TV Shows  
- USA contributes the highest number of titles  
- Drama and International genres are highly prevalent  
- Certain actors appear frequently across multiple titles  
- Recent years show rapid growth in content addition  

---

##  Tools Used
- PostgreSQL
- pgAdmin
- GitHub

---

##  Author
Lalith Kumar Kasula
