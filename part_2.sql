-- question 1: 
SELECT CATEGORY_TITLE
FROM table_youtube_category
GROUP BY CATEGORY_TITLE
HAVING COUNT(*) > 1;

-- question 2: 
SELECT CATEGORY_TITLE 
FROM table_youtube_category
GROUP BY CATEGORY_TITLE
HAVING COUNT(DISTINCT COUNTRY)=1;

-- question 3: 
SELECT DISTINCT CATEGORYID FROM table_youtube_final
WHERE CATEGORY_TITLE IS NULL;

-- question 4: 
UPDATE table_youtube_final
SET CATEGORY_TITLE = 
    (SELECT DISTINCT CATEGORYID FROM table_youtube_final
    WHERE CATEGORY_TITLE IS NULL)
WHERE CATEGORY_TITLE IS NULL;

-- question 5: 
SELECT DISTINCT TITLE FROM table_youtube_final
WHERE CHANNELTITLE IS NULL;

-- question 6:
DELETE FROM table_youtube_final
WHERE VIDEO_ID = '#NAME?';

-- question 7:
CREATE OR REPLACE TABLE table_youtube_duplicates AS
WITH RankedRows AS (
    SELECT 
        *, 
        ROW_NUMBER() OVER (
            PARTITION BY VIDEO_ID, COUNTRY, TRENDING_DATE 
            ORDER BY VIEW_COUNT DESC
        ) AS row_num
    FROM table_youtube_final
)
SELECT *
FROM RankedRows
WHERE row_num > 1;

-- question 8:
DELETE FROM table_youtube_final C
USING table_youtube_duplicates D
WHERE C.ID = D.ID;

-- question 9:
SELECT COUNT(*)
FROM table_youtube_final;