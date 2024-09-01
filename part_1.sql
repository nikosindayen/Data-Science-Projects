-- create and use the assignment_1 database
CREATE DATABASE assignment_1;
USE DATABASE assignment_1;

-- create stage 'stage_assignment' and linked the files stored in azure through generated URL and credentials
CREATE OR REPLACE STAGE stage_assignment
URL = 'azure://endsstorage1.blob.core.windows.net/assignment1'
CREDENTIALS=(AZURE_SAS_TOKEN='?sv=2022-11-02&ss=b&srt=co&sp=rwdlaciytfx&se=2024-12-30T18:45:49Z&st=2024-08-26T11:45:49Z&spr=https&sig=kp4xk1ozCbWwAah22ue%2BKTOFCRuFxkPNMY95rAbFgwY%3D')
;

-- create CSV file type 
CREATE OR REPLACE FILE FORMAT file_format_csv
TYPE = 'CSV'
FIELD_DELIMITER = ','
SKIP_HEADER = 1
NULL_IF = ('\\N', 'NULL', 'NUL', '')
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
;

-- create external table 'ex_table_youtube_trending' from the CSV files stored in the azure container and format the table using the CSV file format created in the previous line
CREATE OR REPLACE EXTERNAL TABLE ex_table_youtube_trending
WITH LOCATION = @stage_assignment
FILE_FORMAT = file_format_csv
PATTERN = '.*[.]csv';


-- create external table 'ex_table_youtube_category' from the JSON files stored in the azure container and format the table
CREATE OR REPLACE EXTERNAL TABLE ex_table_youtube_category
WITH LOCATION = @stage_assignment
FILE_FORMAT = (TYPE=JSON)
PATTERN = '.*[.]json';

-- create table 'table_youtube_trending' from 'ex_table_youtube_trending', format the column names, set the data types of the columns, and add the Country column from the file names of the CSV files.
CREATE OR REPLACE TABLE table_youtube_trending AS
SELECT
    value:c1::VARCHAR AS VIDEO_ID,
    value:c2::VARCHAR AS TITLE,
    value:c3::DATE AS PUBLISHEDAT,
    value:c4::VARCHAR AS CHANNELID,
    value:c5::VARCHAR AS CHANNELTITLE,
    value:c6::INT AS CATEGORYID,
    value:c7::DATE AS TRENDING_DATE,
    value:c8::INT AS VIEW_COUNT,
    value:c9::INT AS LIKES,
    value:c10::INT AS DISLIKES,
    value:c11::INT AS COMMENT_COUNT,
    split_part(metadata$filename, '_', 1) AS COUNTRY
FROM ex_table_youtube_trending;

-- create table 'table_youtube_category' from 'ex_table_youtube_category', format the column through lateral flatten function, format the column names, set the data types of the columns, and add the Country column from the file names of the JSON files.
CREATE OR REPLACE TABLE table_youtube_category AS
SELECT 
  split_part(metadata$filename, '_', 1) AS COUNTRY,
  l.value:id::string as CATEGORYID,
  l.value:snippet:title::string as CATEGORY_TITLE
FROM ex_table_youtube_category, LATERAL FLATTEN(value:items) l;

-- display snippet of table_youtube_trending and check whether the resulting table matches the expected output
SELECT *
FROM table_youtube_trending
WHERE COUNTRY like 'DE'
LIMIT 4;

-- display snippet of table_youtube_category and check whether the resulting table matches the expected output
SELECT *
FROM table_youtube_category
WHERE COUNTRY like 'DE'
LIMIT 6;


-- merge the two tables 'table_youtube_trending' and 'table_youtube_category' through Left Join using CATEGORYID column as reference. Create ID column using UUID_STRING function.
CREATE OR REPLACE TABLE table_youtube_final AS
SELECT 
    UUID_STRING() as ID,
    A.VIDEO_ID,
    A.TITLE,
    A.PUBLISHEDAT,
    A.CHANNELID,
    A.CHANNELTITLE,
    A.CATEGORYID,
    B.CATEGORY_TITLE,
    A.TRENDING_DATE,
    A.VIEW_COUNT,
    A.LIKES,
    A.DISLIKES,
    A.COMMENT_COUNT,
    A.COUNTRY
FROM table_youtube_trending A
LEFT JOIN table_youtube_category B on A.CATEGORYID = B.CATEGORYID and A.COUNTRY = B.COUNTRY;

-- display snippet of table_youtube_final and check whether the resulting table matches the expected output
SELECT *
FROM table_youtube_final
LIMIT 5;

-- count number of rows in the merged table
SELECT COUNT(*)
FROM table_youtube_final;