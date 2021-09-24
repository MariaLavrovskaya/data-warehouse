import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
import os

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
    db_port, db_name, db_user, password = load_database_credentials(db_info)
    print('Database is being created')
    conn = psycopg2.connect(port=db_port, dbname='postgres', user=db_user, password=password)
    conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
    cur = conn.cursor()
    cur.execute('CREATE DATABASE %s ;' %db_name)
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
    
    
    # test
    # cur.execute("CREATE TABLE test (id serial, num integer, data varchar);")
    # conn.commit()
    # cur.close()
    # db_version = cur.fetchone()
    # print(db_version)


if __name__ == "__main__":
    main()





