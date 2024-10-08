-- create table for analysis, table was copied from 'table_youtube_final' but with Music and Entertainment categories deleted 
CREATE OR REPLACE TABLE TABLE_YTANALSIS AS
SELECT *
FROM TABLE_YOUTUBE_FINAL
WHERE CATEGORY_TITLE NOT IN ('Music', 'Entertainment');

-- compute mean and standard deviation for youtube metrics (e.g., views, likes, comments) for every category and create ranking for the metrics
WITH VIDEOSTATS AS (
SELECT CATEGORY_TITLE,
       ROUND((SUM(VIEW_COUNT) / (COUNT(DISTINCT VIDEO_ID))),2) AS AVG_VIEWS_PER_VIDEO,
       ROUND(STDDEV(VIEW_COUNT),2) AS STD_DEV_VIEWS,
       ROUND((SUM(LIKES) / (COUNT(DISTINCT VIDEO_ID))),2) AS AVG_LIKES_PER_VIDEO,
       ROUND(STDDEV(LIKES),2) AS STD_DEV_LIKES,
       ROUND((SUM(COMMENT_COUNT) / (COUNT(DISTINCT VIDEO_ID))),2) AS AVG_COMMENTS_PER_VIDEO,
       ROUND(STDDEV(COMMENT_COUNT),2) AS STD_DEV_COMMENTS,
       COUNT (DISTINCT CHANNELID) AS COMPETITORS,
       COUNT (DISTINCT VIDEO_ID) AS NO_OF_VIDEOS,
       RANK() OVER(ORDER BY AVG_VIEWS_PER_VIDEO DESC) RANK_VIEWS,
       RANK() OVER(ORDER BY AVG_LIKES_PER_VIDEO DESC) RANK_LIKES,
       RANK() OVER(ORDER BY AVG_COMMENTS_PER_VIDEO DESC) RANK_COMMENTS
FROM TABLE_YTANALSIS
GROUP BY CATEGORY_TITLE
ORDER BY AVG_VIEWS_PER_VIDEO DESC)

-- extract the metrics for comaparison: combined rank, metrics (measured in average), metric rank, no. of competition, no. of videos
SELECT 
CATEGORY_TITLE,
ROUND((RANK_VIEWS + RANK_LIKES + RANK_COMMENTS)/3,2) RANK_INTERACTION,
RANK_VIEWS,
AVG_VIEWS_PER_VIDEO,
ROUND((STD_DEV_VIEWS/AVG_VIEWS_PER_VIDEO)*100,2) AS VARIATION_VIEWS,
RANK_LIKES,
AVG_LIKES_PER_VIDEO,
ROUND((STD_DEV_VIEWS/AVG_LIKES_PER_VIDEO)*100,2) AS VARIATION_LIKES,
RANK_COMMENTS,
AVG_COMMENTS_PER_VIDEO, 
ROUND((STD_DEV_VIEWS/AVG_COMMENTS_PER_VIDEO)*100,2) AS VARIATION_COMMENTS,
COMPETITORS,
NO_OF_VIDEOS
FROM VIDEOSTATS
ORDER BY RANK_INTERACTION;

-- category analysis of youtube metrics per country (similar to CTE of previous query but with the Country dimension)
WITH VIDEOSTATS AS (
SELECT CATEGORY_TITLE,
       COUNTRY,
       ROUND((SUM(VIEW_COUNT) / (COUNT(DISTINCT VIDEO_ID))),2) AS AVG_VIEWS_PER_VIDEO,
       ROUND(STDDEV(VIEW_COUNT),2) AS STD_DEV_VIEWS,
       ROUND((SUM(LIKES) / (COUNT(DISTINCT VIDEO_ID))),2) AS AVG_LIKES_PER_VIDEO,
       ROUND(STDDEV(LIKES),2) AS STD_DEV_LIKES,
       ROUND((SUM(COMMENT_COUNT) / (COUNT(DISTINCT VIDEO_ID))),2) AS AVG_COMMENTS_PER_VIDEO,
       ROUND(STDDEV(COMMENT_COUNT),2) AS STD_DEV_COMMENTS,
       COUNT (DISTINCT CHANNELID) AS COMPETITORS,
       COUNT (DISTINCT VIDEO_ID) AS NO_OF_VIDEOS,
       RANK() OVER(PARTITION BY COUNTRY ORDER BY AVG_VIEWS_PER_VIDEO DESC) RANK_VIEWS,
       RANK() OVER(PARTITION BY COUNTRY ORDER BY AVG_LIKES_PER_VIDEO DESC) RANK_LIKES,
       RANK() OVER(PARTITION BY COUNTRY ORDER BY AVG_COMMENTS_PER_VIDEO DESC) RANK_COMMENTS,
       RANK() OVER(PARTITION BY COUNTRY ORDER BY COMPETITORS) RANK_COMPETITORS,
       RANK() OVER(PARTITION BY COUNTRY ORDER BY NO_OF_VIDEOS) RANK_VIDEOPOOL
FROM TABLE_YTANALSIS
GROUP BY CATEGORY_TITLE, COUNTRY
ORDER BY AVG_VIEWS_PER_VIDEO DESC)

-- extract performance of chosen category per country
SELECT 
COUNTRY,
ROUND((RANK_VIEWS + RANK_LIKES + RANK_COMMENTS)/3,2) RANK_INTERACTION,
RANK_VIEWS,
AVG_VIEWS_PER_VIDEO,
ROUND((STD_DEV_VIEWS/AVG_VIEWS_PER_VIDEO)*100,2) AS VARIATION_VIEWS,
RANK_LIKES,
AVG_LIKES_PER_VIDEO,
ROUND((STD_DEV_VIEWS/AVG_LIKES_PER_VIDEO)*100,2) AS VARIATION_LIKES,
RANK_COMMENTS,
AVG_COMMENTS_PER_VIDEO, 
ROUND((STD_DEV_VIEWS/AVG_COMMENTS_PER_VIDEO)*100,2) AS VARIATION_COMMENTS,
COMPETITORS,
NO_OF_VIDEOS,
RANK_COMPETITORS,
RANK_VIDEOPOOL
FROM VIDEOSTATS
WHERE CATEGORY_TITLE LIKE '%Film%'
ORDER BY RANK_INTERACTION;