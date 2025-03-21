USE baby_names_db;
-- Objective 1: Track changes in name popularity

-- Task 1: Find the overall most popular girl and boy names and show how they have changed in popularity rankings over the years

SELECT
    Name, SUM(Births) AS num_babies
FROM
    names
WHERE 
    Gender = 'F'
GROUP BY
    Name
ORDER BY
    num_babies DESC
LIMIT 1;
-- Jessica

SELECT
    Name, SUM(Births) AS num_babies
FROM
    names
WHERE 
    Gender = 'M'
GROUP BY
    Name
ORDER BY
    num_babies DESC
LIMIT 1;
-- Michael

SELECT 
	*
FROM
(WITH girl_names AS (
    SELECT 
        Year, Name, SUM(Births) AS num_babies
    FROM
        names
    WHERE
        Gender = 'F'
    GROUP BY
        Year, Name
)
SELECT
	Year, Name, ROW_NUMBER() OVER (PARTITION BY Year ORDER BY num_babies DESC) AS popularity
FROM
	girl_names) AS popular_girl_names
WHERE
	Name = 'Jessica';

SELECT 
	*
FROM
(WITH boy_names AS (
    SELECT 
        Year, Name, SUM(Births) AS num_babies
    FROM
        names
    WHERE
        Gender = 'M'
    GROUP BY
        Year, Name
)
SELECT
	Year, Name, ROW_NUMBER() OVER (PARTITION BY Year ORDER BY num_babies DESC) AS popularity
FROM
	boy_names) AS popular_boy_names
WHERE
	Name = 'Michael';

-- Task 2: Find the names with the biggest jumps in popularity from the first year of the data set to the last year

WITH names_1980 AS(
	WITH all_names AS (
		SELECT Year, Name, SUM(Births) AS num_babies
		FROM names
		GROUP BY Year, Name
	)
	SELECT Year, Name, ROW_NUMBER() OVER (PARTITION BY Year ORDER BY num_babies DESC) AS Popularity
	FROM all_names
	WHERE Year = 1980),
names_2009 AS (
	WITH all_names AS (
		SELECT Year, Name, SUM(Births) AS num_babies
		FROM names
		GROUP BY Year, Name
	)
	SELECT Year, Name, ROW_NUMBER() OVER (PARTITION BY Year ORDER BY num_babies DESC) AS Popularity
	FROM all_names
	WHERE Year = 2009
)
SELECT t1.Year, t1.Name, t1.Popularity AS Popularity_1980, t2. Popularity AS Popularity_2009, CAST(t2.Popularity AS SIGNED)- CAST(t1.Popularity AS SIGNED) AS Difference
FROM names_1980 t1 
INNER JOIN names_2009 t2 
ON t1.Name = t2.Name
ORDER BY Difference ASC;

-- Objective 2: Compare popularity across decades
-- Task 1: For each year, return the 3 most popular girl names and 3 most popular boy names
WITH boy_names AS(
	SELECT Year, Name, SUM(Births) AS num_babies
	FROM names
    WHERE Gender = 'M'
	GROUP BY Year, Name
),
ranked_boy_names AS(
	SELECT Year, Name, ROW_NUMBER() OVER (PARTITION BY Year ORDER BY num_babies DESC) AS Popularity
	FROM boy_names
),
top_boy_names AS(
	SELECT Year, Name, Popularity
	FROM ranked_boy_names
	WHERE Popularity < 4
),
girl_names AS(
	SELECT Year, Name, SUM(Births) AS num_babies
	FROM names
    WHERE Gender = 'F'
	GROUP BY Year, Name
),
ranked_girl_names AS(
	SELECT Year, Name, ROW_NUMBER() OVER (PARTITION BY Year ORDER BY num_babies DESC) AS Popularity
	FROM girl_names
),
top_girl_names AS(
	SELECT Year, Name, Popularity
	FROM ranked_girl_names
	WHERE Popularity < 4
)
SELECT b.Year, b.Popularity, b.Name BoyName, g.Name GirlName
FROM top_boy_names b
JOIN top_girl_names g ON b.Year = g.Year AND b.Popularity = g.Popularity
ORDER BY b.Year, b.Popularity;
-- Task 2: For each decade, return the 3 most popular girl names and 3 most popular boy names
WITH boy_names AS(
	SELECT (
		CASE 
			WHEN Year BETWEEN 1980 AND 1989 THEN '1980s'
			WHEN Year BETWEEN 1990 AND 1999 THEN '1990s'
			WHEN Year BETWEEN 2000 AND 2009 THEN '2000s'
            ELSE 'None'
            END
		) AS Decade,
		Name, SUM(Births) AS num_babies
	FROM names
    WHERE Gender = 'M'
	GROUP BY Decade, Name
),
ranked_boy_names AS(
	SELECT Decade, Name, ROW_NUMBER() OVER (PARTITION BY Decade ORDER BY num_babies DESC) AS Popularity
	FROM boy_names
),
top_boy_names AS(
	SELECT Decade, Name, Popularity
	FROM ranked_boy_names
	WHERE Popularity < 4
),
girl_names AS(
	SELECT (
		CASE 
			WHEN Year BETWEEN 1980 AND 1989 THEN '1980s'
			WHEN Year BETWEEN 1990 AND 1999 THEN '1990s'
			WHEN Year BETWEEN 2000 AND 2010 THEN '2000s'
            ELSE 'None'
            END
		) AS Decade,
		Name, SUM(Births) AS num_babies
	FROM names
    WHERE Gender = 'F'
	GROUP BY Decade, Name
),
ranked_girl_names AS(
	SELECT Decade, Name, ROW_NUMBER() OVER (PARTITION BY Decade ORDER BY num_babies DESC) AS Popularity
	FROM girl_names
),
top_girl_names AS(
	SELECT Decade, Name, Popularity
	FROM ranked_girl_names
	WHERE Popularity < 4
)
SELECT b.Decade, b.Popularity, b.Name BoyName, g.Name GirlName
FROM top_boy_names b
JOIN top_girl_names g ON b.Decade = g.Decade AND b.Popularity = g.Popularity
ORDER BY b.Decade, b.Popularity;
-- Objective 3: Compare popularity across regions

-- Task 1: Return the number of babies born in each of the six regions (NOTE: The state of MI should be in the Midwest region)

-- Task 2: Return the 3 most popular girl names and 3 most popular boy names within each region

-- Objective 4: Explore unique names in the dataset

-- Task 1: Find the 10 most popular androgynous names (names given to both females and males)

-- Task 2: Find the length of the shortest and longest names, and identify the most popular short names (those with the fewest characters) and long names (those with the most characters)

-- Task 3: The founder of Maven Analytics is named Chris. Find the state with the highest percent of babies named "Chris"