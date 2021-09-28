-- This file includes a number of SQL commands 


-- Print volumes for bitcoin and ethereum on  2018-01-01
SELECT b.volume, e.volume FROM bitcoin b full outer join  ethereum e on b.date=e.date where (b.date='2018-01-01' and e.date= '2018-01-01');

-- Create a temporary table that will hold information of the volumes of all the currency pairs on 2018-01-01
create temp table if not exists temp_volumes (
    index int GENERATED ALWAYS AS IDENTITY,
    Date date,
    Volumes NUMERIC
);

-- Fill the following table with the data of the volumes of all the currency pairs on 2018-01-01
INSERT INTO temp_volumes (Date, Volumes)
SELECT b.date, b.volume
FROM bitcoin b
WHERE date='2018-01-01';

--Count the number of entries in the temporary table 
SELECT count(*) FROM temp_volumes;

--Count the number of volumes in the bitcoin table that has the count greater than two. Since this is done purely for education purposes this query reveals whether  there are any duplicates
SELECT volume, count(*) AS volume_count FROM bitcoin GROUP BY volume HAVING count(*)>2;

-- We now want to combine resultsets of two SELECT statements. Recall that UNION combines the values of the two tables and removes duplicates. If we do not want duplicates to be removed, we can use UNION ALL (really slow)
SELECT volume FROM bitcoin UNION SELECT volume FROM ethereum;


----- One query
--Now we want to update the existing record with the new data -- say, we want to add record for the 2021-27-09 if it does not exist. To do that, we use UPSERT statement, which is a combination of INSERT and UPDATE. 
--We do not want to insert info if the date with the record already exists, thus we use ON CONFLICT clause (ON CONFLICT TARGET ACTION). 
INSERT INTO bitcoin(date, volume) VALUES('2021-09-27', '31013653888') ON CONFLICT DO NOTHING; -- Option 1. This does not update the row if the row already exists

-- To use the ON CONFLICT DO UPDATE SET, we need a primary key that is unique that is relates to the date. Due to the fact that there are duplicates in the data. We first need to delete duplicates from the bitcoin table
DELETE FROM bitcoin
SELECT date FROM bitcoin GROUP BY date HAVING COUNT(*) > 1; --Rows that qualify as duplicates
and not id in (SELECT min(id) from bitcoin group by date); -- Rows that we want to keep

--Then we add primary key so we have one unique constraint
ALTER TABLE bitcoin ADD CONSTRAINT bitcoin_date_pkey PRIMARY KEY (date);

