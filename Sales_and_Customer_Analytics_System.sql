-- ==========================================================
-- Sales and Customer Analytics System
-- Student: Sarulatha P | Register Number: C4S38004
-- ==========================================================

-- ---------- 1. TABLE CREATION ----------

CREATE TABLE Customer (
CustomerID INT PRIMARY KEY,
CustomerName VARCHAR(50),
City VARCHAR(50)
);

CREATE TABLE Product (
ProductID INT PRIMARY KEY,
ProductName VARCHAR(50),
Category VARCHAR(50),
Price INT
);

CREATE TABLE Orders (
OrderID INT PRIMARY KEY,
CustomerID INT,
ProductID INT,
OrderDate DATE,
Quantity INT,
FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);

-- ---------- 2. SAMPLE DATA ----------

INSERT INTO Customer VALUES
(1, 'Arun', 'Chennai'),
(2, 'Kumar', 'Madurai'),
(3, 'Ravi', 'Trichy'),
(4, 'Divya', 'Coimbatore'),
(5, 'Meena', 'Salem');

INSERT INTO Product VALUES
(101, 'Laptop', 'Electronics', 50000),
(102, 'Mobile', 'Electronics', 20800),
(103, 'Headset', 'Accessories', 800),
(104, 'Keyboard', 'Accessories', 1200),
(105, 'Office Chair', 'Furniture', 4500),
(106, 'Study Desk', 'Furniture', 7000);

INSERT INTO Orders VALUES
(1, 1, 101, '2026-08-01', 1),
(2, 2, 102, '2026-08-02', 1),
(3, 2, 103, '2026-08-03', 2),
(4, 3, 103, '2026-08-04', 1),
(5, 1, 104, '2026-08-05', 1),
(6, 4, 101, '2026-08-06', 1),
(7, 3, 105, '2026-08-07', 1),
(8, 2, 106, '2026-08-08', 1),
(9, 5, 102, '2026-08-09', 2),
(10, 1, 103, '2026-08-10', 3);

-- ---------- 3. AGGREGATE FUNCTIONS: COUNT, SUM, AVG, MIN, MAX ----------
-- Shows overall order statistics in one query

SELECT
COUNT(OrderID) AS TotalOrders,
SUM(Orders.Quantity * Product.Price) AS TotalSales,
AVG(Orders.Quantity * Product.Price) AS AverageOrderValue,
MIN(Orders.Quantity * Product.Price) AS SmallestOrder,
MAX(Orders.Quantity * Product.Price) AS LargestOrder
FROM Orders
JOIN Product ON Orders.ProductID = Product.ProductID;

-- ---------- 4. TOTAL SALES REPORT (day-wise) ----------

SELECT
Orders.OrderDate,
COUNT(Orders.OrderID) AS OrdersOnThisDate,
SUM(Orders.Quantity * Product.Price) AS DailySales
FROM Orders
JOIN Product ON Orders.ProductID = Product.ProductID
GROUP BY Orders.OrderDate
ORDER BY Orders.OrderDate;

-- ---------- 5. TOP CUSTOMERS BY PURCHASE AMOUNT ----------

SELECT
Customer.CustomerName,
COUNT(Orders.OrderID) AS TotalOrders,
SUM(Orders.Quantity * Product.Price) AS TotalPurchaseAmount
FROM Orders
JOIN Customer ON Orders.CustomerID = Customer.CustomerID
JOIN Product ON Orders.ProductID = Product.ProductID
GROUP BY Customer.CustomerName
ORDER BY TotalPurchaseAmount DESC;

-- ---------- 6. BEST-SELLING PRODUCTS ----------

SELECT
Product.ProductName,
SUM(Orders.Quantity) AS UnitsSold,
SUM(Orders.Quantity * Product.Price) AS RevenueGenerated
FROM Orders
JOIN Product ON Orders.ProductID = Product.ProductID
GROUP BY Product.ProductName
ORDER BY UnitsSold DESC;

-- ---------- 7. CATEGORY-WISE SALES ANALYSIS ----------

SELECT
Product.Category,
COUNT(Orders.OrderID) AS TotalOrders,
SUM(Orders.Quantity) AS UnitsSold,
SUM(Orders.Quantity * Product.Price) AS TotalRevenue
FROM Orders
JOIN Product ON Orders.ProductID = Product.ProductID
GROUP BY Product.Category
ORDER BY TotalRevenue DESC;
