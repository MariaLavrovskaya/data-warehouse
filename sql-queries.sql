-- This file includes a number of SQL commands 


-- 1. Print volumes for bitcoin and ethereum on  2018-01-01
SELECT b.volume, e.volume FROM bitcoin b full outer join  ethereum e on b.date=e.date where (b.date='2018-01-01' and e.date= '2018-01-01');

-- 2. Create a temporary table that will hold information of the volumes of all the currency pairs on 2018-01-01
create temp table if not exists temp_volumes (
    index int GENERATED ALWAYS AS IDENTITY,
    Date date,
    Volumes NUMERIC
);

-- 3. Fill the following table with the data of the volumes of all the currency pairs on 2018-01-01
INSERT INTO temp_volumes (Date, Volumes)
SELECT b.date, b.volume
FROM bitcoin b
WHERE date='2018-01-01';

--4. Count the number of entries in the temporary table 
SELECT count(*) FROM temp_volumes;

--5. Count the number of volumes in the bitcoin table that has the count greater than two. Since this is done purely for education purposes this query reveals whether  there are any duplicates
SELECT volume, count(*) AS volume_count FROM bitcoin GROUP BY volume HAVING count(*)>2;

-- 6. We now want to combine resultsets of two SELECT statements. Recall that UNION combines the values of the two tables and removes duplicates. If we do not want duplicates to be removed, we can use UNION ALL (really slow)
SELECT volume FROM bitcoin UNION SELECT volume FROM ethereum;


----- 7. One query
--Now we want to update the existing record with the new data -- say, we want to add record for the 2021-27-09 if it does not exist. To do that, we use UPSERT statement, which is a combination of INSERT and UPDATE. 
--We do not want to insert info if the date with the record already exists, thus we use ON CONFLICT clause (ON CONFLICT TARGET ACTION). 
INSERT INTO bitcoin(date, volume) VALUES('2021-09-27', '31013653888') ON CONFLICT DO NOTHING; -- Option 1. This does not update the row if the row already exists

-- To use the ON CONFLICT DO UPDATE SET, we need a primary key that is unique that is relates to the date. Due to the fact that there are duplicates in the data. We first need to delete duplicates from the bitcoin table
DELETE FROM bitcoin
SELECT date FROM bitcoin GROUP BY date HAVING COUNT(*) > 1; --Rows that qualify as duplicates
and not id in (SELECT min(id) from bitcoin group by date); -- Rows that we want to keep

--Then we add primary key so we have one unique constraint
ALTER TABLE bitcoin ADD CONSTRAINT bitcoin_date_pkey PRIMARY KEY (date);


-- 8. Alter some of the entries in the bitcoin table 
-- First we create a temporary table 
CREATE temp table t_bitcoin  AS SELECT * FROM bitcoin;
-- Then we want to alter volume column to show the volume and then 'last updated + current_date'
-- Since volume is of type numeric and we want to add some text first, we need to cast the types. We update the type of the column
ALTER TABLE t_bitcoin ALTER COLUMN volume TYPE TEXT; 
-- We then update the record 
UPDATE t_bitcoin t SET volume = t.volume || 'last updated ' || current_date::text;


-- 9. We want to delete some queries that meet our like clause and save them in CTE. We work with the same t_bitcoin table created previously
CREATE temp table delete_bitcoin as select * from bitcoin limit 0; -- We create a table where we will save deleted entries
ALTER TABLE delete_bitcoin ALTER COLUMN volume TYPE TEXT;
with t_bitcoin_1 as (delete from t_bitcoin where cast(date as text)  like '2018%' returning *) insert into delete_bitcoin select * from t_bitcoin_1 t; --CTE

-- 10. Count row_number for volume where window frame is the date. 
SELECT volume, row_number() OVER w FROM bitcoin WINDOW w  AS (partition by date); 

-- 11. WINDOW FUNCTIONS. Print the lag(), lead(), ntile(), cume_dist() of the open together with the current open from bitcoin table
SELECT opening, lag(opening) OVER w FROM (SELECT OPEN AS opening FROM bitcoin ) V  window w AS (ORDER BY opening); --print the lag, V after FROM subquery is used as dummy since FROM subquery requires the letter to be there
SELECT bitcoin_opening, lead(bitcoin_opening) OVER w FROM (SELECT OPEN AS bitcoin_opening FROM bitcoin) V WINDOW w AS (ORDER BY bitcoin_opening); --print the lead, V after FROM subquery is used as dummy since FROM subquery requires the letter to be there
SELECT bitcoin_opening, ntile(4) OVER w FROM (SELECT OPEN AS bitcoin_opening FROM bitcoin) V WINDOW w AS (ORDER BY bitcoin_opening); -- group in four buckets
SELECT bitcoin_opening, cume_dist() OVER w FROM (SELECT OPEN AS bitcoin_opening FROM bitcoin) V WINDOW w AS (ORDER BY bitcoin_opening); -- computes the fraction of partition rows that are less then or equal to the current row and its peers, according to the definition of the cumulative distribution 

-- 12. More advanced window functions using the FRAME clause. Here we show how ROWS start_point and end_point can be used. We can also use RANGE which combines all the rows it comes across with non-unique values.
select x, sum(x) over w from (select open as x from bitcoin) V window w as (order by x rows between unbounded preceding and current row); -- Unbounded preceding in the first row, whereas current row is the running row. This gives "running" sum from first row till last. 
select x, sum(x) over w from (select open as x from bitcoin) V window w as (order by x rows between current row and unbounded following); -- Unbounded following "fixes" the the cursor on the last value and current row is the one we are currently at. That's why the sum starts decreasing.

