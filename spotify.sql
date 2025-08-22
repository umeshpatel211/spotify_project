
-- Advanced SQL Project -- Spotify Datasets

-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

select * from spotify;

-- EDA 
SELECT COUNT(*) FROM spotify;

SELECT COUNT(DISTINCT artist) FROM spotify;

SELECT COUNT(DISTINCT album) FROM spotify;

SELECT DISTINCT album_type FROM spotify;

SELECT MAX(duration_min) FROM spotify;
SELECT MIN(duration_min) FROM spotify;

SELECT * FROM spotify 
WHERE duration_min = 0;

DELETE FROM spotify 
WHERE duration_min = 0;
SELECT * FROM spotify 
WHERE duration_min = 0;


SELECT DISTINCT channel FROM spotify;
SELECT DISTINCT most_played_on FROM spotify;


------------------------------------------
-- Data Analsis - Easy Category
------------------------------------------
/*
Retrieve the names of all tracks that have more than 1 billion streams.
List all albums along with their respective artists.
Get the total number of comments for tracks where licensed = TRUE.
Find all tracks that belong to the album type single.
Count the total number of tracks by each artist.
*/

-- Q.1 Retrieve the names of all tracks that have more than 1 billion streams.
SELECT * FROM spotify 
WHERE stream > 1000000000;


-- Q.2 List all albums along with their respective artists.
SELECT 
	DISTINCT album, artist 
FROM spotify
ORDER BY 1;


-- Q.3 Get the total number of comments for tracks where licensed = TRUE.
SELECT 
	SUM(comments)
FROM spotify
WHERE licensed = 'true';


-- Q.4 Find all tracks that belong to the album type single.
SELECT * FROM spotify
WHERE album_type = 'single';


-- Q.5 Count the total number of tracks by each artist.
SELECT 
	artist, 
	COUNT(track) AS count_of_track
FROM spotify
GROUP BY artist
ORDER BY 2;




---------------------------------------------
-- Data Analsis - Medium Level
---------------------------------------------
/*
Calculate the average danceability of tracks in each album.
Find the top 5 tracks with the highest energy values.
List all tracks along with their views and likes where official_video = TRUE.
For each album, calculate the total views of all associated tracks.
Retrieve the track names that have been streamed on Spotify more than YouTube.
*/

-- Q.1 Calculate the average danceability of tracks in each album.
SELECT 
	album, 
	AVG(danceability) as avd_danceability
FROM spotify
GROUP BY album
ORDER BY 2 DESC;


-- Q.2 Find the top 5 tracks with the highest energy values.
SELECT 
	DISTINCT track,
	max(energy) AS highest_energy
FROM spotify
GROUP BY track
ORDER BY highest_energy desc 
LIMIT 5;


-- Q.3 List all tracks along with their views and likes where official_video = TRUE.
SELECT 
	track,
	sum(views) AS total_views,
	sum(likes) AS total_likes
FROM spotify
WHERE official_video = 'true'
GROUP BY track
ORDER BY 2 DESC;


-- Q.4 For each album, calculate the total views of all associated tracks.
SELECT
	DISTINCT album,
	track,
	SUM(views)
FROM spotify
GROUP BY album, track
ORDER BY album asc;


-- Q.5 Retrieve the track names that have been streamed on Spotify more than YouTube.
SELECT * FROM
(SELECT 
	track,
	-- most_played_on,
	COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END),0) as stream_on_youtube,
	COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END),0) as stream_on_spotify
FROM spotify
Group By 1) as t1
WHERE 
	stream_on_youtube < stream_on_spotify
	AND
	stream_on_youtube <> 0;




--------------------------------------------------
-- Data Analsis - Advanced Level
--------------------------------------------------
/*
Find the top 3 most-viewed tracks for each artist using window functions.
Write a query to find tracks where the liveness score is above the average.
Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
Find tracks where the energy-to-liveness ratio is greater than 1.2.
Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
*/

-- Q.1 Find the top 3 most-viewed tracks for each artist using window functions.
SELECT artist, track, total_views FROM
(SELECT 
	artist,
	track,
	SUM(views) as total_views,
	dense_rank() OVER(PARTITION BY artist ORDER BY SUM(views) DESC) AS rank_
FROM spotify
group by artist,track)
WHERE rank_ <=3
ORDER BY 1 ASC, 3 DESC;

	
-- Q.2 Write a query to find tracks where the liveness score is above the average.
SELECT 
	track,
	liveness
FROM spotify
WHERE liveness >
(SELECT avg(liveness) FROM spotify);


-- Q.3 Use a WITH clause to calculate the difference between the highest and 
--     lowest energy values for tracks in each album.
WITH cte
AS
(SELECT
 	album,
	MAX(energy) as max_energy,
	MIN(energy) as min_energy
FROM spotify
GROUP BY 1)

SELECT 
	album,
	max_energy - min_energy as energy_diff
FROM  cte
ORDER BY energy_diff DESC;


-- Q.4 Find tracks where the energy-to-liveness ratio is greater than 1.2.
SELECT 
    track,
    artist,
    energy,
    liveness,
    energy/ NULLIF(liveness, 0) AS energy_liveness_ratio
FROM spotify
WHERE (energy / NULLIF(liveness, 0)) > 1.2;


-- Q.5  Calculate the cumulative sum of likes for tracks ordered by 
--      the number of views, using window functions.
SELECT 
	track,
	SUM(likes) OVER (PARTITION BY track order by views desc) AS total_likes
FROM spotify;













