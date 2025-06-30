import psycopg2

#####################################################
##  Database Connection
#####################################################

'''
Connect to the database using the connection string
'''
def openConnection():
    # connection parameters - ENTER YOUR LOGIN AND PASSWORD HERE

    myHost = ""
    userid = ""
    passwd = ""
    
    # Create a connection to the database
    conn = None
    try:
        # connect to postgres, use your own password
        conn = psycopg2.connect(database="postgres",
                                    user="postgres",
                                    password="123456",
                                    host="localhost")

    except psycopg2.Error as sqle:
        print("psycopg2.Error : " + sqle.pgerror)
    
    # return the connection to use
    return conn

'''
Validate salesperson based on username and password
Returns None if login failed, otherwise returns a list [username, firstname, lastname]
'''
def checkLogin(login, password):
    # check input not empty
    if not login or not password or not isinstance(login, str) or not isinstance(password, str):
        return None
        
    # Remove any whitespace
    login = login.strip()
    password = password.strip()
    
    # Check for empty strings after stripping
    if not login or not password:
        return None
        
    conn = openConnection()
    if not conn:
        return None
        
    cur = conn.cursor()
    try:
        # check if username exists (case-insensitive)
        cur.execute("SELECT COUNT(*) FROM Salesperson WHERE LOWER(UserName) = LOWER(%s)", (login,))
        count = cur.fetchone()[0]
        if count == 0:
            return None
            
        # check username (case-insensitive) and password (case-sensitive)
        cur.execute("SELECT UserName, FirstName, LastName FROM Salesperson WHERE LOWER(UserName) = LOWER(%s) AND Password = %s", (login, password))
        result = cur.fetchone()
        return list(result) if result else None # return user info as list
    except psycopg2.Error as e:
        print("Database error:", e)
        return None
    finally:
        if cur and not cur.closed:
            cur.close()
        if conn:
            conn.close()

"""
    Retrieves the summary of car sales.
    This method fetches the summary of car sales from the database and returns it 
    as a collection of summary objects. Each summary contains key information 
    about a particular car sale.
    :return: A list of car sale summaries.
"""
def getCarSalesSummary():
    conn = openConnection()
    cur = conn.cursor()
    # get summary from db
    cur.execute("SELECT * FROM get_car_sales_summary()")
    result = cur.fetchall()
    cur.close()
    conn.close()
    summary = []
    for row in result:
        # build dict for each row, keys match template
        summary.append({
            'make': row[0],
            'model': row[1],
            'availableUnits': row[2],
            'soldUnits': row[3],
            'soldTotalPrices': float(row[4]) if row[4] else 0.0,
            'lastPurchaseAt': row[5] if row[5] else ''
        })
    return summary

"""
    Finds car sales based on the provided search string.
    This method searches the database for car sales that match the provided search 
    string. See assignment description for search specification
    :param search_string: The search string to use for finding car sales in the database.
    :return: A list of car sales matching the search string.
"""
def findCarSales(searchString):
    conn = openConnection()
    cur = conn.cursor()
    if not searchString:
        searchString = '' # if no search, use empty string
    # call SQL function to search
    cur.execute("SELECT * FROM find_car_sales(%s)", (searchString,))
    result = cur.fetchall()
    cur.close()
    conn.close()
    carsale_list = []
    for row in result:
        # build dict for each car, keys match template
        carsale_list.append({
            'carsale_id': row[0],
            'make': row[1],
            'model': row[2],
            'builtYear': row[3],
            'odometer': row[4],
            'price': float(row[5]),
            'isSold': row[6],
            'sale_date': row[7] if row[7] else '',
            'buyer': row[8] if row[8] else '',
            'salesperson': row[9] if row[9] else ''
        })
    return carsale_list

"""
    Adds a new car sale to the database.
    This method accepts a CarSale object, which contains all the necessary details 
    for a new car sale. It inserts the data into the database and returns a confirmation 
    of the operation.
    :param car_sale: The CarSale object to be added to the database.
    :return: A boolean indicating if the operation was successful or not.
"""
def addCarSale(make, model, builtYear, odometer, price):
    try:
        conn = openConnection()
        cur = conn.cursor()
        # call SQL to add new car
        cur.execute("SELECT add_car_sale(%s, %s, %s, %s, %s)", (make, model, int(builtYear), int(odometer), float(price)))
        conn.commit()
        cur.close()
        conn.close()
        return True
    except Exception as e:
        print(e)
        return False

"""
    Updates an existing car sale in the database.
    This method updates the details of a specific car sale in the database, ensuring
    that all fields of the CarSale object are modified correctly. It assumes that 
    the car sale to be updated already exists.
    :param car_sale: The CarSale object containing updated details for the car sale.
    :return: A boolean indicating whether the update was successful or not.
"""
def updateCarSale(carsaleid, customer, salesperson, saledate):
    try:
        conn = openConnection()
        cur = conn.cursor()
        # convert date to dd-mm-yyyy if needed
        if saledate:
            import datetime
            if isinstance(saledate, str):
                try:
                    date_obj = datetime.datetime.strptime(saledate, '%Y-%m-%d')
                    saledate = date_obj.strftime('%d-%m-%Y') # must match SQL format
                except Exception:
                    pass
        else:
            saledate = None
        # call SQL to update car as sold
        cur.execute("SELECT update_car_sale(%s, %s, %s, %s)", (int(carsaleid), customer, salesperson, saledate))
        conn.commit()
        cur.close()
        conn.close()
        return True
    except Exception as e:
        print("Update error:", e)
        return False
    