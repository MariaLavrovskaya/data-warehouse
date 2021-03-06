# data-warehouse

## Toy Data Warehouse Project in PostgreSQL
This project is meant to use python and SQL in building out a data warehouse that will be used for future quantitative research projects.

## Getting started 
This code repository builds a Postgre database on your local machine. Here we use yfinance data to get historical data on crypto pairs -- otherwise, any other csv file 
can be used to build database with the data you need. This code is meant to build the database in PostgreSQL using Python and Bash. We first define a very simple SQL schema
that involves one-to-one and many-to-une relationships. This design can be improved by introducing more data with more complex many-to-many relationships. 

## Requirements
Python (we use 3.9.7)  
PostgreSQL==13.4  
pandas==1.3.2  
yfinance==0.1.63  

## Structure

1. **data folder** shows how crypto pairs can be retrieved and further saved into csv using yfinance and pandas. This is done purely for demonstration purposes. 
2. **connect.py** shows how to create a database and then build two tables inside PostgreSQL. Information table contains basic information about each cryptocurrency. All other tables which are named after each crypto pair hold daily information on each pair (Open, high, low, close. adj close and volume). 
3. **fill.py** shows how to fill the created tables with the information from csv files. The final result should be the database which contains all the retrieved information stored in PostgreSQL database. 
4. **sql-queries.sql** lists some of the SQL queries required for the analysis. 
