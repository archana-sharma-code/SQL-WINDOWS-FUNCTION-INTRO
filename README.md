# Task 23 – SQL Window Functions Intro

**Track:** Data Analytics | **Level 2 – Day 23** | **Tools:** SQL (SQLite for running; SQL Server version also included)

## Objective
Use `ROW_NUMBER`, `RANK`, `DENSE_RANK` and `LAG` to answer business questions and learn analytical SQL patterns.

## Approach
1. Wrote 12 queries: 4 for `ROW_NUMBER`, 4 for `RANK`/`DENSE_RANK`, 4 for `LAG`.
2. Found that window functions cannot be used in a `WHERE` clause. Queries 3 and 7 (top-N per group) compute the rank in a CTE and filter on it in the outer query.
3. Ran everything on a small **sample database** (`sample.db`) with Northwind/AdventureWorks-style tables, since the full datasets were not installed. The outputs below come from that sample data (12 employees, 12 products, 3 categories, 200 orders in 2024). The logic carries over unchanged to AdventureWorks or Northwind after renaming tables/columns.

## Files
| File | Purpose |
|---|---|
| `queries.sql` | 12 queries, SQLite syntax (runs on `sample.db`) |
| `queries_sqlserver.sql` | Same queries in SQL Server syntax (`YEAR()`, `DATEDIFF()`) |
| `sample.db` | Sample SQLite database used to generate outputs |
| `outputs.txt` | Output of every query (first 8 rows) |

## How to run
Open `sample.db` in [DB Browser for SQLite](https://sqlitebrowser.org/) or sqliteonline.com, then run each query from `queries.sql`.

## The 12 Queries
| # | Function | Business question |
|---|---|---|
| 1 | ROW_NUMBER | Number employees by hire date |
| 2 | ROW_NUMBER | Rank employees by salary within each department |
| 3 | ROW_NUMBER | Top 3 products by sales in each category |
| 4 | ROW_NUMBER | Keep only each customer's first order (de-duplication) |
| 5 | RANK | Rank salespeople by total sales |
| 6 | RANK | Rank products by price within category (ties) |
| 7 | RANK | Top 3 salaries per department, including ties |
| 8 | RANK vs DENSE_RANK | Compare both on sales performance |
| 9 | LAG | Month-over-month sales change and % growth |
| 10 | LAG | Days between a customer's consecutive orders |
| 11 | LAG | Year-over-year sales per employee |
| 12 | LAG | Products with growing/declining monthly sales |

## Outputs (sample data, first 8 rows each)
### Query 1: Assign sequential numbers to employees by hire date  [12 rows, showing up to 8]
```
EmployeeID | FirstName | LastName | HireDate | RowNum
1 | Ava | Smith1 | 2011-02-15 | 1
2 | Ben | Smith2 | 2012-03-15 | 2
3 | Cara | Smith3 | 2013-04-15 | 3
4 | Dev | Smith4 | 2014-05-15 | 4
5 | Eli | Smith5 | 2015-06-15 | 5
6 | Fay | Smith6 | 2016-07-15 | 6
7 | Gus | Smith7 | 2017-08-15 | 7
8 | Hana | Smith8 | 2018-09-15 | 8
```

### Query 2: Rank employees within each department by salary  [12 rows, showing up to 8]
```
DepartmentID | EmployeeID | FirstName | LastName | Salary | SalaryRank
1 | 6 | Fay | Smith6 | 70000 | 1
1 | 9 | Ivan | Smith9 | 70000 | 2
1 | 12 | Lena | Smith12 | 70000 | 3
1 | 3 | Cara | Smith3 | 50000 | 4
2 | 7 | Gus | Smith7 | 70000 | 1
2 | 1 | Ava | Smith1 | 60000 | 2
2 | 4 | Dev | Smith4 | 60000 | 3
2 | 10 | Jia | Smith10 | 60000 | 4
```

### Query 3: Find top 3 products in each category by sales (FIXED: rank in a CTE, filter outside)  [9 rows, showing up to 8]
```
CategoryID | CategoryName | ProductID | ProductName | TotalSales | SalesRank
1 | Cat1 | 12 | Prod12 | 3790.0 | 1
1 | Cat1 | 3 | Prod3 | 3760.0 | 2
1 | Cat1 | 9 | Prod9 | 3460.0 | 3
2 | Cat2 | 7 | Prod7 | 4250.0 | 1
2 | Cat2 | 1 | Prod1 | 3180.0 | 2
2 | Cat2 | 10 | Prod10 | 2640.0 | 3
3 | Cat3 | 5 | Prod5 | 3410.0 | 1
3 | Cat3 | 2 | Prod2 | 3070.0 | 2
```

### Query 4: Remove duplicates - keep only the first occurrence  [15 rows, showing up to 8]
```
OrderID | CustomerID | OrderDate
63 | 1 | 2024-01-11
32 | 2 | 2024-01-21
39 | 3 | 2024-03-17
80 | 4 | 2024-01-08
37 | 5 | 2024-01-11
88 | 6 | 2024-03-07
169 | 7 | 2024-01-23
154 | 8 | 2024-02-12
```

### Query 5: Rank salespeople by total sales (with ties)  [12 rows, showing up to 8]
```
SalesPersonID | FirstName | LastName | TotalSales | SalesRank
9 | Ivan | Smith9 | 4820.0 | 1
3 | Cara | Smith3 | 3900.0 | 2
4 | Dev | Smith4 | 3560.0 | 3
5 | Eli | Smith5 | 3510.0 | 4
11 | Kai | Smith11 | 3430.0 | 5
7 | Gus | Smith7 | 3330.0 | 6
2 | Ben | Smith2 | 3230.0 | 7
6 | Fay | Smith6 | 3010.0 | 8
```

### Query 6: Rank products within each category by price (with ties)  [12 rows, showing up to 8]
```
CategoryID | ProductID | ProductName | ListPrice | PriceRank
1 | 3 | Prod3 | 30.0 | 1
1 | 6 | Prod6 | 20.0 | 2
1 | 9 | Prod9 | 20.0 | 2
1 | 12 | Prod12 | 10.0 | 4
2 | 7 | Prod7 | 20.0 | 1
2 | 1 | Prod1 | 10.0 | 2
2 | 4 | Prod4 | 10.0 | 2
2 | 10 | Prod10 | 10.0 | 2
```

### Query 7: Employees with top 3 salaries in each department, including ties (FIXED)  [11 rows, showing up to 8]
```
DepartmentID | EmployeeID | FirstName | LastName | Salary | SalaryRank
1 | 6 | Fay | Smith6 | 70000 | 1
1 | 9 | Ivan | Smith9 | 70000 | 1
1 | 12 | Lena | Smith12 | 70000 | 1
2 | 7 | Gus | Smith7 | 70000 | 1
2 | 1 | Ava | Smith1 | 60000 | 2
2 | 4 | Dev | Smith4 | 60000 | 2
2 | 10 | Jia | Smith10 | 60000 | 2
3 | 2 | Ben | Smith2 | 80000 | 1
```

### Query 8: Compare RANK vs DENSE_RANK for sales performance  [12 rows, showing up to 8]
```
SalesPersonID | FirstName | LastName | TotalSales | Rank_Score | DenseRank_Score
9 | Ivan | Smith9 | 4820.0 | 1 | 1
3 | Cara | Smith3 | 3900.0 | 2 | 2
4 | Dev | Smith4 | 3560.0 | 3 | 3
5 | Eli | Smith5 | 3510.0 | 4 | 4
11 | Kai | Smith11 | 3430.0 | 5 | 5
7 | Gus | Smith7 | 3330.0 | 6 | 6
2 | Ben | Smith2 | 3230.0 | 7 | 7
6 | Fay | Smith6 | 3010.0 | 8 | 8
```

### Query 9: Compare current month sales with previous month  [12 rows, showing up to 8]
```
Year | Month | TotalSales | PreviousMonthSales | SalesGrowth | GrowthPercentage
2024 | 1 | 3030.0 |  |  | 
2024 | 2 | 1710.0 | 3030.0 | -1320.0 | -43.6
2024 | 3 | 1680.0 | 1710.0 | -30.0 | -1.8
2024 | 4 | 2000.0 | 1680.0 | 320.0 | 19.0
2024 | 5 | 3400.0 | 2000.0 | 1400.0 | 70.0
2024 | 6 | 2940.0 | 3400.0 | -460.0 | -13.5
2024 | 7 | 5430.0 | 2940.0 | 2490.0 | 84.7
2024 | 8 | 3100.0 | 5430.0 | -2330.0 | -42.9
```

### Query 10: Track customer order history and time between orders  [200 rows, showing up to 8]
```
CustomerID | OrderID | OrderDate | PreviousOrderDate | DaysSinceLastOrder
1 | 63 | 2024-01-11 |  | 
1 | 111 | 2024-04-05 | 2024-01-11 | 85
1 | 85 | 2024-04-14 | 2024-04-05 | 9
1 | 172 | 2024-05-22 | 2024-04-14 | 38
1 | 178 | 2024-05-24 | 2024-05-22 | 2
1 | 150 | 2024-07-22 | 2024-05-24 | 59
1 | 179 | 2024-09-19 | 2024-07-22 | 59
1 | 14 | 2024-09-27 | 2024-09-19 | 8
```

### Query 11: Compare employee performance year over year  [12 rows, showing up to 8]
```
EmployeeID | FirstName | LastName | FiscalYear | TotalSales | PreviousYearSales | YearOverYearGrowth
1 | Ava | Smith1 | 2024 | 2370.0 |  | 
2 | Ben | Smith2 | 2024 | 3230.0 |  | 
3 | Cara | Smith3 | 2024 | 3900.0 |  | 
4 | Dev | Smith4 | 2024 | 3560.0 |  | 
5 | Eli | Smith5 | 2024 | 3510.0 |  | 
6 | Fay | Smith6 | 2024 | 3010.0 |  | 
7 | Gus | Smith7 | 2024 | 3330.0 |  | 
8 | Hana | Smith8 | 2024 | 2580.0 |  |
```

### Query 12: Find products with declining sales trends  [125 rows, showing up to 8]
```
ProductID | ProductName | Year | Month | TotalSales | PreviousMonthSales | Trend
1 | Prod1 | 2024 | 2 | 60.0 | 400.0 | Declining
1 | Prod1 | 2024 | 3 | 220.0 | 60.0 | Growing
1 | Prod1 | 2024 | 4 | 210.0 | 220.0 | Declining
1 | Prod1 | 2024 | 5 | 130.0 | 210.0 | Declining
1 | Prod1 | 2024 | 6 | 20.0 | 130.0 | Declining
1 | Prod1 | 2024 | 7 | 220.0 | 20.0 | Growing
1 | Prod1 | 2024 | 8 | 180.0 | 220.0 | Declining
1 | Prod1 | 2024 | 9 | 360.0 | 180.0 | Growing
```

## Notes
**ROW_NUMBER vs RANK vs DENSE_RANK**
- `ROW_NUMBER()` gives every row a unique number, even when values tie. Use it for de-duplication or picking exactly N rows per group.
- `RANK()` gives tied rows the same number and then skips numbers (1, 2, 2, 4). See Query 6, where three products tie at rank 2 in a category.
- `DENSE_RANK()` also gives ties the same number but does not skip (1, 2, 2, 3). In Query 8 the sample sales totals have no ties, so both columns match. With tied totals they would differ.

**LAG**
- `LAG(col, n, default) OVER (PARTITION BY ... ORDER BY ...)` reads a value from `n` rows earlier in the same partition.
- The first row in a partition has no previous row, so `LAG` returns NULL unless a default is given. In Query 9 I left it NULL so the first month shows no growth instead of a misleading figure.
- Query 12 compares each month with the product's previous month *that had sales*, so months with zero sales are skipped.

**Gotchas I ran into**
- Window functions are not allowed in `WHERE`. Wrap the query in a CTE or subquery, then filter on the rank (Queries 3 and 7).
- Always add `ORDER BY` inside `OVER()` for ranking and `LAG`, otherwise the result is not deterministic.
- Use `NULLIF(x, 0)` when dividing by a `LAG` value to avoid divide-by-zero (Query 9).
- `YEAR()`, `MONTH()` and `DATEDIFF()` are SQL Server functions. SQLite uses `strftime()` and `julianday()`, so both versions are included.

## Interview Questions
**1. RANK vs DENSE_RANK?**
Both give tied rows the same rank. `RANK` leaves gaps after ties (1, 2, 2, 4) while `DENSE_RANK` does not (1, 2, 2, 3). Use `RANK` when the gap matters, such as competition standings, and `DENSE_RANK` when you want consecutive levels, such as "top 3 distinct salaries".

**2. When use LAG?**
When you need to compare a row with an earlier row without a self-join: month-over-month or year-over-year growth, time between events (days between orders), or spotting increasing or decreasing trends.

## Outcome
Completed 12 window-function queries covering ranking, top-N per group, de-duplication and trend analysis, with outputs and notes.
