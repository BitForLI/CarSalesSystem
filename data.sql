-- By default, PostgreSQL recognizes the American format MM/DD/YYYY. It needs to be changed to the Australian format of the date
SET datestyle TO DMY;

DROP TABLE IF EXISTS Make;
DROP TABLE IF EXISTS Model;
DROP TABLE IF EXISTS Salesperson;
DROP TABLE IF EXISTS Customer;
DROP TABLE IF EXISTS CarSales;

CREATE TABLE Salesperson (
    UserName VARCHAR(10) PRIMARY KEY,
    Password VARCHAR(20) NOT NULL,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
	UNIQUE(FirstName, LastName)
);

INSERT INTO Salesperson VALUES 
('jdoe', 'Pass1234', 'John', 'Doe'),
('brown', 'Passwxyz', 'Bob', 'Brown'),
('ksmith1', 'Pass5566', 'Karen', 'Smith');

CREATE TABLE Customer (
    CustomerID VARCHAR(10) PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Mobile VARCHAR(20) NOT NULL
);

INSERT INTO Customer VALUES 
('c001', 'David', 'Wilson', '4455667788'),
('c899', 'Eva', 'Taylor', '5566778899'),
('c199',  'Frank', 'Anderson', '6677889900'),
('c910', 'Grace', 'Thomas', '7788990011'),
('c002',  'Stan', 'Martinez', '8899001122'),
('c233', 'Laura', 'Roberts', '9900112233'),
('c123', 'Charlie', 'Davis', '7712340011'),
('c321', 'Jane', 'Smith', '9988990011'),
('c211', 'Alice', 'Johnson', '7712222221');

CREATE TABLE Make (
    MakeCode VARCHAR(5) PRIMARY KEY,
    MakeName VARCHAR(20) UNIQUE NOT NULL
);

INSERT INTO Make VALUES ('MB', 'Mercedes Benz');
INSERT INTO Make VALUES ('TOY', 'Toyota');
INSERT INTO Make VALUES ('VW', 'Volkswagen');
INSERT INTO Make VALUES ('LEX', 'Lexus');
INSERT INTO Make VALUES ('LR', 'Land Rover');

CREATE TABLE Model (
    ModelCode VARCHAR(10) PRIMARY KEY,
    ModelName VARCHAR(20) UNIQUE NOT NULL,
    MakeCode VARCHAR(10) NOT NULL,  
    FOREIGN KEY (MakeCode) REFERENCES Make(MakeCode)
);

INSERT INTO Model (ModelCode, ModelName, MakeCode) VALUES
('aclass', 'A Class', 'MB'),
('cclass', 'C Class', 'MB'),
('eclass', 'E Class', 'MB'),
('camry', 'Camry', 'TOY'),
('corolla', 'Corolla', 'TOY'),
('rav4', 'RAV4', 'TOY'),
('defender', 'Defender', 'LR'),
('rangerover', 'Range Rover', 'LR'),
('discosport', 'Discovery Sport', 'LR'),
('golf', 'Golf', 'VW'),
('passat', 'Passat', 'VW'),
('troc', 'T Roc', 'VW'),
('ux', 'UX', 'LEX'),
('gx', 'GX', 'LEX'),
('nx', 'NX', 'LEX');

CREATE TABLE CarSales (
  CarSaleID SERIAL primary key,
  MakeCode VARCHAR(10) NOT NULL REFERENCES Make(MakeCode),
  ModelCode VARCHAR(10) NOT NULL REFERENCES Model(ModelCode),
  BuiltYear INTEGER NOT NULL CHECK (BuiltYear BETWEEN 1950 AND EXTRACT(YEAR FROM CURRENT_DATE)),
  Odometer INTEGER NOT NULL,
  Price Decimal(10,2) NOT NULL,
  IsSold Boolean NOT NULL,
  BuyerID VARCHAR(10) REFERENCES Customer,
  SalespersonID VARCHAR(10) REFERENCES Salesperson,
  SaleDate Date
);

INSERT INTO CarSales (MakeCode, ModelCode, BuiltYear, Odometer, Price, IsSold, BuyerID, SalespersonID, SaleDate) VALUES
('MB', 'cclass', 2020, 64210, 72000.00, TRUE, 'c001', 'jdoe', '01/03/2024'),
('MB', 'eclass', 2019, 31210, 89000.00, FALSE, NULL, NULL, NULL),
('TOY', 'camry', 2021, 98200, 37200.00, TRUE, 'c123', 'brown', '07/12/2023'),
('TOY', 'corolla', 2022, 65000, 35000.00, TRUE, 'c910', 'jdoe', '21/09/2024'),
('LR', 'defender', 2018, 115000, 97000.00, FALSE, NULL, NULL, NULL),
('VW', 'golf', 2023, 22000, 33000.00, TRUE, 'c233', 'jdoe', '06/11/2023'),
('LEX', 'nx', 2020, 67000, 79000.00, TRUE, 'c321', 'brown', '01/01/2025'),
('LR', 'discosport', 2021, 43080, 85000.00, TRUE, 'c211', 'ksmith1', '27/01/2021'),
('TOY', 'rav4', 2019, 92900, 48000.00, FALSE, NULL, NULL, NULL),
('MB', 'aclass', 2022, 47000, 57000.00, TRUE, 'c199', 'jdoe', '01/03/2025'),
('LEX', 'ux', 2023, 23000, 70000.00, TRUE, 'c899', 'brown', '01/01/2023'),
('VW', 'passat', 2020, 63720, 42000.00, FALSE, NULL, NULL, NULL),
('MB', 'eclass', 2021, 12000, 155000.00, TRUE, 'c002', 'ksmith1', '01/10/2024'),
('LR', 'rangerover', 2017, 60000, 128000.00, FALSE, NULL, NULL, NULL),
('TOY', 'camry', 2025, 10, 49995.00, FALSE, NULL, NULL, NULL),
('LR', 'discosport', 2022, 53000, 89900.00, FALSE, NULL, NULL, NULL),
('MB', 'cclass', 2023, 55000, 82100.00, FALSE, NULL, NULL, NULL),
('MB', 'aclass', 2025, 5, 78000.00, FALSE, NULL, NULL, NULL),
('MB', 'aclass', 2015, 8912, 12000.00, TRUE, 'c199', 'jdoe', '11/03/2020'),
('TOY', 'camry', 2024, 21000, 42000.00, FALSE, NULL, NULL, NULL),
('LEX', 'gx', 2025, 6, 128085.00, FALSE, NULL, NULL, NULL),
('MB', 'eclass', 2019, 99220, 105000.00, FALSE, NULL, NULL, NULL),
('VW', 'golf', 2023, 53849, 43000.00, FALSE, NULL, NULL, NULL),
('MB', 'cclass', 2022, 89200, 62000.00, FALSE, NULL, NULL, NULL);

----------------------------------
-- Assignment-2- Five Functions --
----------------------------------

-- 1. checkLogin (for login)
-- check if login ok
DROP FUNCTION IF EXISTS check_login(TEXT, TEXT);

CREATE OR REPLACE FUNCTION check_login(username TEXT, password TEXT)
RETURNS TABLE (UserName TEXT, FirstName TEXT, LastName TEXT) AS $$
    -- get user if username and password match (case-insensitive)
    SELECT UserName, FirstName, LastName
    FROM Salesperson
    WHERE LOWER(UserName) = LOWER(username) 
    AND Password = password; -- only right password can login
$$ LANGUAGE sql;

-- 2. getCarSalesSummary (for viewing car sales summary)
-- show summary table
DROP FUNCTION IF EXISTS get_car_sales_summary();
CREATE OR REPLACE FUNCTION get_car_sales_summary()
RETURNS TABLE (
    make TEXT,
    model TEXT,
    availableUnits INT,
    soldUnits INT,
    soldTotalPrices NUMERIC,
    lastPurchaseAt TEXT
) AS $$
    -- 以 Model 为主表，LEFT JOIN CarSales，确保所有车型都出现
    SELECT mk.MakeName, md.ModelName,
        COUNT(cs.*) FILTER (WHERE cs.IsSold = FALSE) AS availableUnits,
        COUNT(cs.*) FILTER (WHERE cs.IsSold = TRUE) AS soldUnits,
        COALESCE(SUM(cs.Price) FILTER (WHERE cs.IsSold = TRUE), 0) AS soldTotalPrices,
        TO_CHAR(MAX(CASE WHEN cs.IsSold = TRUE THEN cs.SaleDate ELSE NULL END), 'DD-MM-YYYY') AS lastPurchaseAt
    FROM Model md
    JOIN Make mk ON md.MakeCode = mk.MakeCode
    LEFT JOIN CarSales cs ON cs.ModelCode = md.ModelCode
    GROUP BY mk.MakeCode, mk.MakeName, md.ModelCode, md.ModelName
    ORDER BY mk.MakeName, md.ModelName;
$$ LANGUAGE sql;

-- 3. findCarSales (for finding car sales)
-- search car list
CREATE OR REPLACE FUNCTION find_car_sales(keyword TEXT)
RETURNS TABLE (CarSaleID INT, Make TEXT, Model TEXT, BuiltYear INT,Odometer INT,Price NUMERIC,IsSold BOOLEAN,SaleDate TEXT,Buyer TEXT,Salesperson TEXT
) AS $$
-- return car info, filter by keyword
SELECT
    cs.CarSaleID,
    mk.MakeName,
    md.ModelName,
    cs.BuiltYear,
    cs.Odometer,
    cs.Price,
    cs.IsSold,
    CASE WHEN cs.IsSold THEN TO_CHAR(cs.SaleDate, 'DD-MM-YYYY') ELSE NULL END AS SaleDate, -- only show date if sold
    CASE WHEN cs.IsSold THEN c.FirstName || ' ' || c.LastName ELSE NULL END AS Buyer, -- only show buyer if sold
    CASE WHEN cs.IsSold THEN s.FirstName || ' ' || s.LastName ELSE NULL END AS Salesperson -- only show salesperson if sold
FROM CarSales cs
JOIN Make mk ON cs.MakeCode = mk.MakeCode
JOIN Model md ON cs.ModelCode = md.ModelCode
LEFT JOIN Customer c ON cs.BuyerID = c.CustomerID
LEFT JOIN Salesperson s ON cs.SalespersonID = s.UserName
WHERE (
    LOWER(mk.MakeName) LIKE LOWER('%' || keyword || '%') -- search by make
    OR LOWER(md.ModelName) LIKE LOWER('%' || keyword || '%') -- or model
    OR (
        cs.IsSold AND (
            LOWER(c.FirstName || ' ' || c.LastName) LIKE LOWER('%' || keyword || '%') -- or buyer
            OR LOWER(s.FirstName || ' ' || s.LastName) LIKE LOWER('%' || keyword || '%') -- or salesperson
        )
    )
    OR (keyword IS NULL OR keyword = '') -- show all if no keyword
)
AND (cs.IsSold = FALSE OR (cs.IsSold = TRUE AND cs.SaleDate >= (CURRENT_DATE - INTERVAL '3 years'))) -- only show recent sold
ORDER BY cs.IsSold ASC, cs.SaleDate ASC NULLS FIRST, mk.MakeName ASC, md.ModelName ASC
$$ LANGUAGE sql;

-- 4. addCarSale (for adding a car sale)
-- add new car
CREATE OR REPLACE FUNCTION add_car_sale(make_name TEXT, model_name TEXT, built_year INT, odometer INT, price NUMERIC)
RETURNS VOID AS $$
DECLARE
    make_code VARCHAR(5);
    model_code VARCHAR(10);
BEGIN
    -- check odometer positive
    IF odometer <= 0 THEN
        RAISE EXCEPTION 'Odometer must be greater than 0. Given: %', odometer; -- must be >0
    END IF;
    -- check price positive
    IF price <= 0 THEN
        RAISE EXCEPTION 'Price must be greater than 0. Given: %', price; -- must be >0
    END IF;

    -- get make code (case-insensitive)
    SELECT MakeCode INTO make_code 
    FROM Make 
    WHERE LOWER(MakeName) = LOWER(make_name);

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid make name: %', make_name; -- make must exist
    END IF;

    -- get model code (case-insensitive)
    SELECT ModelCode INTO model_code 
    FROM Model 
    WHERE LOWER(ModelName) = LOWER(model_name);

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid model name: %', model_name; -- model must exist
    END IF;

    -- insert new car, default unsold
    INSERT INTO CarSales (
        MakeCode, ModelCode, BuiltYear, Odometer, Price, IsSold
    )
    VALUES (
        make_code, model_code, built_year, odometer, price, FALSE
    );
END;
$$ LANGUAGE plpgsql;

-- 5. updateCarSale (for updating a car sale)
-- mark car sold
DROP FUNCTION IF EXISTS update_car_sale(integer, text, text, text);

CREATE OR REPLACE FUNCTION update_car_sale(p_carsaleid INT, p_customerid TEXT, p_salesperson_username TEXT, p_sale_date TEXT)
RETURNS VOID AS $$
BEGIN
    -- check customer exists
    IF NOT EXISTS (
        SELECT 1 FROM Customer 
        WHERE LOWER(Customer.CustomerID) = LOWER(p_customerid)
    ) THEN
        RAISE EXCEPTION 'Invalid customer ID: %', p_customerid; -- must be valid customer
    END IF;

    -- check salesperson exists
    IF NOT EXISTS (
        SELECT 1 FROM Salesperson 
        WHERE LOWER(Salesperson.UserName) = LOWER(p_salesperson_username)
    ) THEN
        RAISE EXCEPTION 'Invalid salesperson username: %', p_salesperson_username; -- must be valid salesperson
    END IF;

    -- check date not in future
    IF TO_DATE(p_sale_date, 'DD-MM-YYYY') > CURRENT_DATE THEN
        RAISE EXCEPTION 'Sale date cannot be in the future: %', p_sale_date; -- can't sell in future
    END IF;

    -- update car as sold
    UPDATE CarSales
    SET BuyerID = (
            SELECT Customer.CustomerID FROM Customer 
            WHERE LOWER(Customer.CustomerID) = LOWER(p_customerid)
        ),
        SalespersonID = (
            SELECT Salesperson.UserName FROM Salesperson 
            WHERE LOWER(Salesperson.UserName) = LOWER(p_salesperson_username)
        ),
        SaleDate = TO_DATE(p_sale_date, 'DD-MM-YYYY'),
        IsSold = TRUE
    WHERE CarSaleID = p_carsaleid;
END;
$$ LANGUAGE plpgsql;