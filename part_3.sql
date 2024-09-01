-- Question 1: selected country, title, channel title, view count, and computed the rank of each title in terms of view count for each country from the table 'table_youtube_final', then restricted the table to show only those rank 1-3, finally, ordered the table based on country name and then on rank from 1 to 3.
SELECT COUNTRY, 
       TITLE,
       CHANNELTITLE,
       VIEW_COUNT, 
       RANK() OVER(PARTITION BY COUNTRY ORDER BY VIEW_COUNT DESC) AS RK
FROM TABLE_YOUTUBE_FINAL
WHERE CATEGORY_TITLE LIKE 'Gaming' AND TRENDING_DATE = '2024-04-01'
QUALIFY RK <=3
ORDER BY COUNTRY, 
         RK;

-- Question 2: selected country, and counted the number of distinct videos with 'bts' (case-insensitive) in its title as 'CT' column from the table 'table_youtube_final'
SELECT COUNTRY, 
       COUNT(DISTINCT VIDEO_ID) AS CT
FROM TABLE_YOUTUBE_FINAL
WHERE LOWER(TITLE) LIKE '%bts%'
GROUP BY COUNTRY
ORDER BY CT DESC;

-- Question 3: created a CTE 'DATA2024' containing, country, month, year, title, channel title, category title, view count, likes ratio, and rank of the video for the year 2024 based on view count extracted from the table 'table_youtube_final'. Then, using DATA2024, created the year_month column by concatenating year and month data, and selected title, channel title, category title, view count and likes ratio of the top 1 most viewed video of each country. 
WITH DATA2024 AS (
SELECT 
    COUNTRY,
    EXTRACT(MONTH FROM TRENDING_DATE) AS M,
    EXTRACT(YEAR FROM TRENDING_DATE) AS Y,
    TITLE,
    CHANNELTITLE,
    CATEGORY_TITLE,
    VIEW_COUNT,
    ROUND((LIKES / VIEW_COUNT)*100,2) AS LIKES_RATIO,
    RANK() OVER(PARTITION BY COUNTRY, M ORDER BY VIEW_COUNT DESC) AS RK
FROM TABLE_YOUTUBE_FINAL
WHERE Y = 2024
QUALIFY RK = 1
)

SELECT COUNTRY,
    (Y || '-0' || M || '-01') AS YEAR_MONTH,
    TITLE,
    CHANNELTITLE,
    CATEGORY_TITLE,
    VIEW_COUNT,
    LIKES_RATIO
FROM DATA2024
ORDER BY 
    YEAR_MONTH, COUNTRY;

-- Question 4: Created a CTE 'categorycountrydata2022' containing country, category title, total videos per category computed by counting the distinct video_id for each category, then the rank of the category on each country based on number of videos, then created another CTE 'countrydata2022', showing the total distinct videos for each country then created a table by merging the two CTEs based on the country column. Then created added column in the resulting table computing the percentage of distinct videos under the top 1 category of each country over the total distinct videos viewed in the country.
WITH CATEGORYCOUNTRYDATA2022 AS (
    SELECT COUNTRY,
           CATEGORY_TITLE,
           COUNT(DISTINCT VIDEO_ID) AS TOTAL_CATEGORY_VIDEO,
           RANK() OVER (PARTITION BY COUNTRY ORDER BY TOTAL_CATEGORY_VIDEO DESC) AS R
    FROM TABLE_YOUTUBE_FINAL
    WHERE EXTRACT(YEAR FROM TRENDING_DATE) >= 2022
    GROUP BY COUNTRY, CATEGORY_TITLE
),
COUNTRYDATA2022 AS (
    SELECT COUNTRY,
           COUNT(DISTINCT VIDEO_ID) AS TOTAL_COUNTRY_VIDEO
    FROM TABLE_YOUTUBE_FINAL
    WHERE EXTRACT(YEAR FROM TRENDING_DATE) >= 2022
    GROUP BY COUNTRY
)
SELECT CC2022.COUNTRY,
       CC2022.CATEGORY_TITLE,
       CC2022.TOTAL_CATEGORY_VIDEO,
       CD2022.TOTAL_COUNTRY_VIDEO,
       ROUND(CC2022.TOTAL_CATEGORY_VIDEO / CD2022.TOTAL_COUNTRY_VIDEO * 100, 2) AS PERCENTAGE
FROM CATEGORYCOUNTRYDATA2022 CC2022
LEFT JOIN COUNTRYDATA2022 CD2022 
    ON CC2022.COUNTRY = CD2022.COUNTRY
WHERE CC2022.R = 1
ORDER BY CC2022.CATEGORY_TITLE, CC2022.COUNTRY;

-- Question 5: Selected channel title then counted all the distinct videos on each channel title, ordered the resulting table from most number of distinct videos to the lowest and created a cutoff to the first channel title. 
SELECT CHANNELTITLE,
    COUNT(DISTINCT VIDEO_ID) CHANNELVID
FROM TABLE_YOUTUBE_FINAL
GROUP BY CHANNELTITLE
ORDER BY CHANNELVID DESC
LIMIT 1;
