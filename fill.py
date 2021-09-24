import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
import os
import pandas as pd 
from connect import load_database_credentials

def fill_info_table(db_info):
    """ Fill the information table with the data from csv file 
    Parameters
    ----------
     db_info: string 
              the string holding txt file
    """
    db_port, db_name, db_user, password = load_database_credentials(db_info)
    try:
        conn = psycopg2.connect(port=db_port, dbname=db_name, user=db_user, password=password)
        cur = conn.cursor()
        cur.execute(""" COPY information(abbrevation, name) 
                        FROM '/Users/user/Desktop/book/data-warehouse/data/information.csv' 
                        DELIMITER ',' 
                        CSV HEADER; 
                        """)
        conn.commit()
        cur.close()
    except (Exception, psycopg2.DatabaseError) as error:
        # if any errors raised, print the error and delete whatever was created
        print(error)
    





def main():
    db_info = 'database_info.txt'
    fill_info_table(db_info)

if __name__ == "__main__":
    main()