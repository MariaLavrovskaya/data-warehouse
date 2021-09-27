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