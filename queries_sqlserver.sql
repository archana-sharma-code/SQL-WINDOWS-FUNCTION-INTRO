-- Task 23: SQL Window Functions Intro
-- Using ROW_NUMBER, RANK, and LAG for business questions
-- Dataset: AdventureWorks (compatible schema)

-- ============================================================================
-- ROW_NUMBER() Examples
-- ============================================================================

-- Query 1: Assign sequential numbers to employees by hire date
SELECT 
    EmployeeID,
    FirstName,
    LastName,
    HireDate,
    ROW_NUMBER() OVER (ORDER BY HireDate) AS RowNum
FROM Employee
ORDER BY HireDate;

-- Query 2: Rank employees within each department by salary
SELECT 
    DepartmentID,
    EmployeeID,
    FirstName,
    LastName,
    Salary,
    ROW_NUMBER() OVER (PARTITION BY DepartmentID ORDER BY Salary DESC) AS SalaryRank
FROM Employee
ORDER BY DepartmentID, Salary DESC;

-- Query 3: Find top 3 products in each category by sales (FIXED: rank in a CTE, filter outside)
WITH CategorySales AS (
    SELECT 
        c.CategoryID,
        c.CategoryName,
        p.ProductID,
        p.ProductName,
        SUM(od.Quantity * od.UnitPrice) AS TotalSales
    FROM Category c
    JOIN Product p ON c.CategoryID = p.CategoryID
    JOIN OrderDetail od ON p.ProductID = od.ProductID
    GROUP BY c.CategoryID, c.CategoryName, p.ProductID, p.ProductName
),
Ranked AS (
    SELECT 
        CategoryID, CategoryName, ProductID, ProductName, TotalSales,
        ROW_NUMBER() OVER (PARTITION BY CategoryID ORDER BY TotalSales DESC) AS SalesRank
    FROM CategorySales
)
SELECT CategoryID, CategoryName, ProductID, ProductName, TotalSales, SalesRank
FROM Ranked
WHERE SalesRank <= 3
ORDER BY CategoryID, TotalSales DESC;

-- Query 4: Remove duplicates - keep only the first occurrence
WITH RankedOrders AS (
    SELECT 
        OrderID,
        CustomerID,
        OrderDate,
        ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS OrderNum
    FROM [Order]
)
SELECT 
    OrderID,
    CustomerID,
    OrderDate
FROM RankedOrders
WHERE OrderNum = 1
ORDER BY CustomerID;

-- ============================================================================
-- RANK() Examples
-- ============================================================================

-- Query 5: Rank salespeople by total sales (with ties)
SELECT 
    SalesPersonID,
    FirstName,
    LastName,
    TotalSales,
    RANK() OVER (ORDER BY TotalSales DESC) AS SalesRank
FROM (
    SELECT 
        sp.SalesPersonID,
        e.FirstName,
        e.LastName,
        SUM(so.TotalDue) AS TotalSales
    FROM SalesPerson sp
    JOIN Employee e ON sp.SalesPersonID = e.EmployeeID
    JOIN SalesOrderHeader so ON sp.SalesPersonID = so.SalesPersonID
    GROUP BY sp.SalesPersonID, e.FirstName, e.LastName
) AS SalesSummary
ORDER BY TotalSales DESC;

-- Query 6: Rank products within each category by price (with ties)
SELECT 
    CategoryID,
    ProductID,
    ProductName,
    ListPrice,
    RANK() OVER (PARTITION BY CategoryID ORDER BY ListPrice DESC) AS PriceRank
FROM Product
ORDER BY CategoryID, ListPrice DESC;

-- Query 7: Employees with top 3 salaries in each department, including ties (FIXED)
WITH Ranked AS (
    SELECT 
        DepartmentID, EmployeeID, FirstName, LastName, Salary,
        RANK() OVER (PARTITION BY DepartmentID ORDER BY Salary DESC) AS SalaryRank
    FROM Employee
)
SELECT DepartmentID, EmployeeID, FirstName, LastName, Salary, SalaryRank
FROM Ranked
WHERE SalaryRank <= 3
ORDER BY DepartmentID, Salary DESC;

-- Query 8: Compare RANK vs DENSE_RANK for sales performance
SELECT 
    SalesPersonID,
    FirstName,
    LastName,
    TotalSales,
    RANK() OVER (ORDER BY TotalSales DESC) AS Rank_Score,
    DENSE_RANK() OVER (ORDER BY TotalSales DESC) AS DenseRank_Score
FROM (
    SELECT 
        sp.SalesPersonID,
        e.FirstName,
        e.LastName,
        SUM(so.TotalDue) AS TotalSales
    FROM SalesPerson sp
    JOIN Employee e ON sp.SalesPersonID = e.EmployeeID
    JOIN SalesOrderHeader so ON sp.SalesPersonID = so.SalesPersonID
    GROUP BY sp.SalesPersonID, e.FirstName, e.LastName
) AS SalesSummary
ORDER BY TotalSales DESC;

-- ============================================================================
-- LAG() Examples
-- ============================================================================

-- Query 9: Compare current month sales with previous month
SELECT 
    Year,
    Month,
    TotalSales,
    LAG(TotalSales) OVER (ORDER BY Year, Month) AS PreviousMonthSales,
    TotalSales - LAG(TotalSales) OVER (ORDER BY Year, Month) AS SalesGrowth,
    (TotalSales - LAG(TotalSales) OVER (ORDER BY Year, Month)) * 100.0 / 
        NULLIF(LAG(TotalSales) OVER (ORDER BY Year, Month), 0) AS GrowthPercentage
FROM (
    SELECT 
        YEAR(OrderDate) AS Year,
        MONTH(OrderDate) AS Month,
        SUM(TotalDue) AS TotalSales
    FROM SalesOrderHeader
    GROUP BY YEAR(OrderDate), MONTH(OrderDate)
) AS MonthlySales
ORDER BY Year, Month;

-- Query 10: Track customer order history and time between orders
SELECT 
    CustomerID,
    OrderID,
    OrderDate,
    LAG(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS PreviousOrderDate,
    DATEDIFF(DAY, LAG(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate), OrderDate) AS DaysSinceLastOrder
FROM [Order]
ORDER BY CustomerID, OrderDate;

-- Query 11: Compare employee performance year over year
SELECT 
    EmployeeID,
    FirstName,
    LastName,
    FiscalYear,
    TotalSales,
    LAG(TotalSales) OVER (PARTITION BY EmployeeID ORDER BY FiscalYear) AS PreviousYearSales,
    TotalSales - LAG(TotalSales) OVER (PARTITION BY EmployeeID ORDER BY FiscalYear) AS YearOverYearGrowth
FROM (
    SELECT 
        e.EmployeeID,
        e.FirstName,
        e.LastName,
        YEAR(so.OrderDate) AS FiscalYear,
        SUM(so.TotalDue) AS TotalSales
    FROM Employee e
    JOIN SalesOrderHeader so ON e.EmployeeID = so.SalesPersonID
    GROUP BY e.EmployeeID, e.FirstName, e.LastName, YEAR(so.OrderDate)
) AS EmployeeSales
ORDER BY EmployeeID, FiscalYear;

-- Query 12: Find products with declining sales trends
WITH ProductMonthlySales AS (
    SELECT 
        ProductID,
        ProductName,
        Year,
        Month,
        TotalSales,
        LAG(TotalSales) OVER (PARTITION BY ProductID ORDER BY Year, Month) AS PreviousMonthSales
    FROM (
        SELECT 
            p.ProductID,
            p.ProductName,
            YEAR(so.OrderDate) AS Year,
            MONTH(so.OrderDate) AS Month,
            SUM(od.Quantity * od.UnitPrice) AS TotalSales
        FROM Product p
        JOIN OrderDetail od ON p.ProductID = od.ProductID
        JOIN SalesOrderHeader so ON od.SalesOrderID = so.SalesOrderID
        GROUP BY p.ProductID, p.ProductName, YEAR(so.OrderDate), MONTH(so.OrderDate)
    ) AS MonthlyData
)
SELECT 
    ProductID,
    ProductName,
    Year,
    Month,
    TotalSales,
    PreviousMonthSales,
    CASE 
        WHEN PreviousMonthSales > TotalSales THEN 'Declining'
        WHEN PreviousMonthSales < TotalSales THEN 'Growing'
        ELSE 'Stable'
    END AS Trend
FROM ProductMonthlySales
WHERE PreviousMonthSales IS NOT NULL
ORDER BY ProductID, Year, Month;
