import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
import os
import pandas as pd



def load_database_credentials(db_info):
    """ Load text file with credentials 
     Parameters
     ----------
     db_info: string 
              the string holding txt file
     Returns 
     ---------
     lines: list 
            Holds 4 values that are used as credentials to connect to the database
    """
    current_path = os.getcwd()
    # load the database credentials 
    f = open(current_path + '/' +db_info)
    lines = f.readlines()[1:][0].split(',')
    return lines 



def create_database(db_info):
    """ Create database if one does not exist
    Parameters
    ----------
    db_info: string 
              the string holding txt file
     """
    db_port, db_name, db_user, password = load_database_credentials(db_info)
    print('Database is being created')
    conn = psycopg2.connect(port=db_port, dbname='postgres', user=db_user, password=password)
    conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
    cur = conn.cursor()
    cur.execute('CREATE DATABASE %s ;' %db_name)
    cur.close()



def create_db_tables(db_info):
    """ Creates tables in the existing database. If error is raised, both tables are deleted
    Parameters
    ----------
    db_info: string 
              the string holding txt file  
     """
    db_port, db_name, db_user, password = load_database_credentials(db_info)
    # with open('/Users/user/Desktop/book/data-warehouse/data/historical_data.csv', newline = '') as csvfile: 
    #     daily_pairs = csv.reader(csvfile, delimiter = ',')
    #     print(daily_pairs[0])
    names = pd.read_csv('/Users/user/Desktop/book/data-warehouse/data/information.csv', header=0)

    try:
        conn = psycopg2.connect(port=db_port, dbname=db_name, user=db_user, password=password)
        cur = conn.cursor()
        cur.execute(""" 
    
                CREATE TABLE information (
                    id SERIAL PRIMARY KEY, 
                    abbrevation TEXT, 
                    name TEXT NOT NULL
                ); """)
        conn.commit()
        for element in names['name']:
            cur.execute(
                """
                CREATE TABLE %s (
                    id integer REFERENCES information (id) ON DELETE CASCADE, --References the primary key created in the information table, if the information is deleted, id is erased
                    Date date,
                    Open NUMERIC, -- Numeric(precision, scale)
                    High NUMERIC, 
                    Low NUMERIC, 
                    Close NUMERIC, 
                    Adj_Close NUMERIC, 
                    Volume NUMERIC
                );
                """ %element)
            conn.commit()
        cur.close()
    except (Exception, psycopg2.DatabaseError) as error:
        # if any errors raised, print the error and delete whatever was created
            print(error)
            conn = psycopg2.connect(port=db_port, dbname=db_name, user=db_user, password=password)
            cur = conn.cursor()
            cur.execute('DROP TABLE information CASCADE;')
            conn.commit()
            for element in names['name']:
                cur.execute('DROP TABLE %s' %element)
                conn.commit()
            # cur.execute('DROP TABLE crypto_pairs')
            cur.close()





def main():
    db_info = 'database_info.txt'
    db_port, db_name, db_user, password = load_database_credentials(db_info)
    # check whether the database exists; if not, create the database 
    try: 
        conn = psycopg2.connect(port=db_port, dbname=db_name, user=db_user, password=password)
        print('Database exists')
    # cur = conn.cursor()
    except:
        create_database(db_info)
    # once the database is created, we create tables inside the database
    create_db_tables(db_info)
    


if __name__ == "__main__":
    main()





