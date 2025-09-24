## Q1. SELECT clause with WHERE, AND, DISTINCT, Wild Card (LIKE

USE classicmodels;

-- a. Task- Fetch employee number, first name, and last name of those employees who are working as Sales Rep and report to employee number 1102.
-- Query:
SELECT employeeNumber, firstName, lastName
FROM employees
WHERE jobTitle = 'Sales Rep'
	AND reportsTO = 1102;
    
-- b. Task- Shoe the unique productline values containing the word cars at the end.
-- Query:
SELECT DISTINCT productline
FROM products
WHERE productLine LIKE '%Cars';

--------------------------------------------------------------------------------------------------------------------------------------------------------------

## Q2. CASE STATEMENTS for Segmentation

-- Task: Segmentatioin customers based on their country into 3 categories:
			-- "North America" for USA or Canada
            -- "Europe" for UK, France or Germany
            -- "Other" for the rest
-- Query:
SELECT customerNumber, customerName,
	CASE
		WHEN country IN ('USA', 'Canada') THEN 'North America'
		WHEN country IN ('UK', 'France', 'Germany') THEN 'Europe'
		ELSE 'Other'
	END AS CustomerSegmrnt
FROM customers;

--------------------------------------------------------------------------------------------------------------------------------------------------------------

## Q3. Group By with Aggregation functions and Having clause, Date and Time functions?

-- a. Task: Identify top 10 products (by productCode) with the highest total order quantity across all orders.
-- Query:
SELECT 
	productCode,
    SUM(quantityOrdered) AS total_quantity
FROM orderdetails
GROUP BY productCode
ORDER BY total_quantity DESC
LIMIT 10;

-- b. Task: Count the number of payments per month using paymentDate, show only those months with more than 20 payments, and sort by count in descending order.
-- Query:
SELECT
	MONTHNAME(paymentDate) AS Month,
    COUNT(*) AS Totalpayments
FROM payments
GROUP BY MONTHNAME(paymentDate)
HAVING COUNT(*) > 20
ORDER BY TotalPayments DESC;

--------------------------------------------------------------------------------------------------------------------------------------------------------------

## Q4. CONSTRAINTS: Primary key, Foreign key, Unique, check, not null, default

-- Task: Create a new database and two tables: Customers and Orders with specific constraints
-- Query-
CREATE DATABASE Customers_Orders;
USE Customers_Orders;

-- a. Create Customers table
-- Query:
CREATE TABLE Customers (
	Customer_ID INT PRIMARY KEY AUTO_INCREMENT,
    First_Name VARCHAR(50) NOT NULL,
    Last_Name VARCHAR(50) NOT NULL,
    Email VARCHAR(255) UNIQUE,
    Phone_Number VARCHAR(20) 
);

-- b. Create Orders table
-- Query: 
CREATE TABLE Orders (
	Order_ID INT PRIMARY KEY AUTO_INCREMENT,
    Customer_ID INT,
    Order_Date DATE,
    Total_Amount DECIMAL(10,2),
    FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID),
    CHECK (Total_Amount > 0)
);

--------------------------------------------------------------------------------------------------------------------------------------------------------------

## Q5. JOINS 
-- Task: List the Top 5 countries(by order count) that Classic Models ship to
-- Query:
USE classicmodels;
SELECT 
	c.country,
    COUNT(o.orderNumber) AS order_count
FROM 
	customers c
JOIN 
	orders o ON c.customerNumber = o.customerNumber
Group BY 
	c.country
Order BY 
	order_count DESC
LIMIT 5;

--------------------------------------------------------------------------------------------------------------------------------------------------------------

## Q6. SELF JOIN 
-- Task:
	-- Create a table named project
    -- Insert sample data
    -- Write a query to display each employee's name and their manager's namae using a self join

-- Create Project table
-- Query:
CREATE TABLE Project (
	EmployeeID INT PRIMARY KEY AUTO_INCREMENT,
    FullName VARCHAR(50) NOT NULL,
    Gender ENUM('Male', 'Female'),
    ManagerID INT
);

-- Insert sample data
-- Query:
INSERT INTO Project(
	EmployeeID, FullName, Gender, ManagerID) VALUES
		(1, 'Pranaya', 'Male', 3),
        (2, 'Priyanka', 'Female', 1),
        (3, 'Preety', 'Female', NULL),
        (4, 'Anurag', 'Male', 1),
        (5, 'Sambit', 'Male', 1),
        (6, 'Rajesh', 'Male', 3),
        (7, 'Hina', 'Female', 3);
		
 -- Self JOIN Query to Show Employees and Their Managers
 -- Query:
 SELECT
	e.FullName AS Employee_Name,
    m.FullName AS Manager_Name
FROM project e
LEFT JOIN project m ON e.ManagerID = m.EmployeeID;

--------------------------------------------------------------------------------------------------------------------------------------------------------------

## Q7.DDL Commands: Create, Alter, Rename
-- Task: 
	-- i. Create a table named Facility 
    -- ii. Alter the table

-- Create Facility table
-- Query:
CREATE TABLE Facility (
	Facility_ID INT,
    Name VARCHAR(100),
    State VARCHAR(100),
    Country VARCHAR(100)
);

-- Alter Table - Add Primary Key and Auto Increment
-- Query:
ALTER TABLE Facility
MODIFY Facility_ID INT PRIMARY KEY AUTO_INCREMENT;

SELECT * FROM Facility;

-- Alter Table - Add City column after name
-- Query:
ALTER TABLE Facility
ADD City VARCHAR(100) NOT NULL AFTER Name;

SELECT * FROM Facility;
DESCRIBE Facility;

--------------------------------------------------------------------------------------------------------------------------------------------------------------

## Q8. Views in SQL
-- Task: Create a view called product_category_sales 
-- Query:
CREATE VIEW product_category_sales AS
SELECT
	p1.productLine,
    ROUND(SUM(od.quantityOrdered * od.priceEach), 2) AS total_sales,
    COUNT(DISTINCT o.orderNumber) AS number_of_orders
FROM productlines p1
JOIN products p ON p1.productLine = p.productLine
JOIN orderdetails od ON p.productCode = od.productCode
JOIN orders o ON od.orderNumber = o.orderNumber
GROUP BY p1.productLine;

SELECT * FROM product_category_sales
ORDER BY total_sales DESC;

--------------------------------------------------------------------------------------------------------------------------------------------------------------

## Q9. Stored Procedures in SQL with parameters
-- Task: Create a stored procedure named Get_country_payment that:
-- Query:
USE classicmodels;

DELIMITER //
CREATE PROCEDURE Get_country_payments (
    IN input_year INT,
    IN input_country VARCHAR(50)
)
BEGIN
    SELECT 
        input_year AS Year,
        input_country AS Country,
        CONCAT(
			ROUND(
				SUM(p.amount)/1000, 2), 'K') AS Total_Amount_K
    FROM payments p
    JOIN customers c ON p.customerNumber = c.customerNumber
    WHERE YEAR(p.paymentDate) = input_year
      AND c.country = input_country;
END //

CALL Get_country_payments(2003, 'France');

--------------------------------------------------------------------------------------------------------------------------------------------------------------

## Q10. Window Function - Rank, Dense_rank, Lead and Lag

-- a. Task: Rank customers based on how frequently they placed orders
-- Query:
SELECT 
    c.customerNumber,
    c.customerName,
    COUNT(o.orderNumber) AS total_orders,
    RANK() OVER (ORDER BY COUNT(o.orderNumber) DESC) AS rank_by_orders,
    DENSE_RANK() OVER (ORDER BY COUNT(o.orderNumber) DESC) AS dense_rank_by_orders
FROM customers c
JOIN orders o ON c.customerNumber = o.customerNumber
GROUP BY c.customerNumber, c.customerName
ORDER BY total_orders DESC;

-- b. Year-wise & Month-wise Order Count + YOY% Change
-- Task: Show count of orders per year and month, Calculate YoY% change using LAG() function, Format % with no decimals
-- Query:
SELECT 
    YEAR(orderDate) AS year,
    MONTHNAME(orderDate) AS month_name,
    COUNT(orderNumber) AS total_orders,
    CONCAT(
        ROUND(
            (COUNT(orderNumber) - LAG(COUNT(orderNumber)) OVER (
                PARTITION BY MONTH(orderDate) ORDER BY YEAR(orderDate)
            )) * 100.0 
            /
            LAG(COUNT(orderNumber)) OVER (
                PARTITION BY MONTH(orderDate) ORDER BY YEAR(orderDate)
            ), 0
        ), '%'
    ) AS YOY_Percentage_Change
FROM orders
GROUP BY YEAR(orderDate), MONTH(orderDate)
ORDER BY MONTH(orderDate), YEAR(orderDate);

--------------------------------------------------------------------------------------------------------------------------------------------------------------

## Q11. Subqueries and their applications
-- Task: Find how many product lines have products with buyPrice greater than the average buyPrice
-- Query:
SELECT 
    productLine,
    COUNT(*) AS count_above_avg_price
FROM products
WHERE buyPrice > (
    SELECT AVG(buyPrice) FROM products
)
GROUP BY productLine;

--------------------------------------------------------------------------------------------------------------------------------------------------------------

## Q12. ERROR HANDLING in SQL
-- Task: 
		-- Create a table Emp_EH
        -- Create stored procedure to insert value into this table
        -- Add exception handling to show a message
-- Create the Table
-- Query:
CREATE TABLE Emp_EH (
	EmpID INT PRIMARY KEY,
    EmpName VARCHAR(100),
    EmailAddress VARCHAR(100)
);

-- Create Procedure with Error Handling
-- Query:
DELIMITER //
CREATE PROCEDURE Insert_Emp_With_Error_Handling (
	IN p_EmpID INT,
    IN p_EmpName VARCHAR(100),
    IN p_EmailAddress VARCHAR(100)
)
BEGIN
	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error occurred' AS Message;
	END;
    
    INSERT INTO Emp_EH (EmpID, EmpName, EmailAddress)
    VALUES (p_EmpID, p_EmpName, p_EmailAddress);
END //

-- Call the Procedure
CALL Insert_Emp_With_Error_Handling(1, 'Alice', 'alice@example.com'); -- Succesful call
CALL Insert_Emp_With_Error_Handling(1, 'Bob', 'bob@example.com'); -- Error call(duplicate key)

--------------------------------------------------------------------------------------------------------------------------------------------------------------

## Q13. Triggers
-- Task: 
		-- Create a table Emp_BIT
        -- Insert Sample data
        -- Create a BEFORE INSERT trigger

-- Create the table
-- Query: 
CREATE TABLE Emp_BIT (
	Name VARCHAR(50),
    Occupation VARCHAR(50),
    Working_date Date,
    Working_hours INT
);

-- Create the Trigger
-- Query
DELIMITER //
CREATE TRIGGER Before_Insert_Working_Hours 
BEFORE INSERT ON Emp_BIT
FOR EACH ROW
BEGIN
	IF NEW.Working_hours < 0 THEN
		SET NEW.Working_hours = ABS(NEW.Working_hours);
	END IF;
END //

-- Insert Data (Including a mix of negative & positive hours)
-- Query:
INSERT INTO Emp_BIT VALUES
	('Robin', 'Scientist', '2020-10-04', 12),  
	('Warner', 'Engineer', '2020-10-04', -10),  
	('Peter', 'Actor', '2020-10-04', 13),  
	('Marco', 'Doctor', '2020-10-04', -14),  
	('Brayden', 'Teacher', '2020-10-04', 12),  
	('Antonio', 'Business', '2020-10-04', -11);
    
SELECT * FROM Emp_BIT;

-------------------------------------------------------------------------END---------------------------------------------------------------------------

