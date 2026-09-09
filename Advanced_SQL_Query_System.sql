-- ==========================================================
-- Advanced SQL Query System (Subqueries & Nested Queries)
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
(106, 'Study Desk', 'Furniture', 7000),
(107, 'Monitor', 'Electronics', 15000);
-- Monitor is added but never ordered below, to demonstrate NOT IN subqueries

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

-- ---------- 3. SUBQUERY: PRODUCTS ABOVE AVERAGE PRICE ----------
-- The inner query calculates the average price first,
-- then the outer query keeps only products priced above it.

SELECT ProductName, Category, Price
FROM Product
WHERE Price > (SELECT AVG(Price) FROM Product)
ORDER BY Price DESC;

-- ---------- 4. SUBQUERY: CUSTOMER WITH MAXIMUM PURCHASE AMOUNT ----------
-- Step 1 (inner): calculate total spend per customer.
-- Step 2 (outer): keep only the row(s) matching the highest total.

SELECT CustomerName, TotalSpent
FROM (
    SELECT Customer.CustomerName AS CustomerName,
           SUM(Orders.Quantity * Product.Price) AS TotalSpent
    FROM Orders
    JOIN Customer ON Orders.CustomerID = Customer.CustomerID
    JOIN Product ON Orders.ProductID = Product.ProductID
    GROUP BY Customer.CustomerID
) AS CustomerTotals
WHERE TotalSpent = (
    SELECT MAX(TotalSpent) FROM (
        SELECT SUM(Orders.Quantity * Product.Price) AS TotalSpent
        FROM Orders
        JOIN Product ON Orders.ProductID = Product.ProductID
        GROUP BY Orders.CustomerID
    )
);

-- ---------- 5. NESTED QUERY: CUSTOMERS WHO SPENT MORE THAN AVERAGE ----------

SELECT CustomerName, TotalSpent
FROM (
    SELECT Customer.CustomerName AS CustomerName,
           SUM(Orders.Quantity * Product.Price) AS TotalSpent
    FROM Orders
    JOIN Customer ON Orders.CustomerID = Customer.CustomerID
    JOIN Product ON Orders.ProductID = Product.ProductID
    GROUP BY Customer.CustomerID
) AS CustomerTotals
WHERE TotalSpent > (
    SELECT AVG(TotalSpent) FROM (
        SELECT SUM(Orders.Quantity * Product.Price) AS TotalSpent
        FROM Orders
        JOIN Product ON Orders.ProductID = Product.ProductID
        GROUP BY Orders.CustomerID
    )
)
ORDER BY TotalSpent DESC;

-- ---------- 6. NESTED QUERY: PRODUCTS THAT WERE NEVER ORDERED ----------
-- NOT IN checks the product list against every ProductID that
-- actually appears in the Orders table.

SELECT ProductName, Category, Price
FROM Product
WHERE ProductID NOT IN (SELECT DISTINCT ProductID FROM Orders);

-- ---------- 7. COMPLEX BUSINESS QUERY: BEST PRODUCT IN EACH CATEGORY ----------
-- A correlated subquery: for every product, it re-checks the
-- best revenue found within that SAME category.

SELECT Product.Category, Product.ProductName,
       SUM(Orders.Quantity * Product.Price) AS Revenue
FROM Orders
JOIN Product ON Orders.ProductID = Product.ProductID
GROUP BY Product.Category, Product.ProductName
HAVING SUM(Orders.Quantity * Product.Price) = (
    SELECT MAX(CategoryRevenue) FROM (
        SELECT SUM(o2.Quantity * p2.Price) AS CategoryRevenue
        FROM Orders o2
        JOIN Product p2 ON o2.ProductID = p2.ProductID
        WHERE p2.Category = Product.Category
        GROUP BY p2.ProductID
    )
)
ORDER BY Revenue DESC;

-- ---------- 8. ADVANCED REPORT: CUSTOMER RANKING BY TOTAL SPEND ----------
-- A correlated subquery counts how many customers spent MORE
-- than the current customer, which becomes that customer's rank.
-- (This is how ranking was done in SQL before RANK()/window functions.)

SELECT
    c.CustomerName,
    ct.TotalSpent,
    (
        SELECT COUNT(*) + 1
        FROM (
            SELECT Orders.CustomerID AS CustomerID,
                   SUM(Orders.Quantity * Product.Price) AS Spent
            FROM Orders
            JOIN Product ON Orders.ProductID = Product.ProductID
            GROUP BY Orders.CustomerID
        ) AS t2
        WHERE t2.Spent > ct.TotalSpent
    ) AS SpendRank
FROM (
    SELECT Orders.CustomerID AS CustomerID,
           SUM(Orders.Quantity * Product.Price) AS TotalSpent
    FROM Orders
    JOIN Product ON Orders.ProductID = Product.ProductID
    GROUP BY Orders.CustomerID
) AS ct
JOIN Customer c ON ct.CustomerID = c.CustomerID
ORDER BY SpendRank;
