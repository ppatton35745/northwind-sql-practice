--Get a list of all the orders processed with category name (as an input parameter) *not implemented yet

--Get the product name , count of orders processed

SELECT ProductName
	,Count(Id) Orders
FROM (
		SELECT p.ProductName
			,o.Id
		FROM [Order] o
		JOIN OrderDetail od on od.OrderId = o.Id
			JOIN Product p on p.Id = od.ProductId
)
GROUP BY ProductName
ORDER BY 2 desc				

--Get the list of the months which don’t have any orders

WITH recursive
	cnt(x) AS (
		SELECT 0
		UNION all
		SELECT x+1
		FROM cnt
		LIMIT (SELECT (
						(
						julianday((SELECT substr(Max(OrderDate),1,10) FROM [Order]))
						- julianday((SELECT substr(Min(OrderDate),1,10) FROM [Order]))
						)
					) + 1
				)
	)
	
SELECT a.*
	,b.*
FROM (
	SELECT strftime('%Y-%m',date(julianday((SELECT substr(Min(OrderDate),1,10) FROM [Order])), '+' || x || ' days')) as date
	FROM cnt a
	GROUP BY strftime('%Y-%m',date(julianday((SELECT substr(Min(OrderDate),1,10) FROM [Order])), '+' || x || ' days'))
) a
LEFT JOIN (
	SELECT substr(OrderDate,1,7) as OrderDate 
	FROM [Order] Group BY substr(OrderDate,1,7)
) b on b.OrderDate = a.date
WHERE b.OrderDate is null

--Get the top 3 products which have the most orders

SELECT od.ProductId
	,p.ProductName
	,Count(od.Quantity) as SumOfQuantity
FROM OrderDetail od
JOIN Product p on p.Id = od.ProductId
GROUP BY od.ProductId
ORDER BY 3 desc
LIMIT 3;

--Get the list of the months which don’t have any orders for product chai

WITH recursive
	cnt(x) AS (
		SELECT 0
		UNION all
		SELECT x+1
		FROM cnt
		LIMIT (SELECT (
						(
						julianday((SELECT substr(Max(OrderDate),1,10) FROM [Order]))
						- julianday((SELECT substr(Min(OrderDate),1,10) FROM [Order]))
						)
					) + 1
				)
	)
	
SELECT a.*
	,b.*
FROM (
	SELECT strftime('%Y-%m',date(julianday((SELECT substr(Min(OrderDate),1,10) FROM [Order])), '+' || x || ' days')) as date
	FROM cnt a
	GROUP BY strftime('%Y-%m',date(julianday((SELECT substr(Min(OrderDate),1,10) FROM [Order])), '+' || x || ' days'))
) a
LEFT JOIN (
	SELECT substr(o.OrderDate,1,7) as OrderDate 
	FROM [Order] o
	JOIN OrderDetail od on od.OrderId = o.Id
		JOIN Product p on p.Id = od.ProductId and p.ProductName = 'Chai'
	Group BY substr(o.OrderDate,1,7)
) b on b.OrderDate = a.date
WHERE b.OrderDate is null

--Get the list of the products which don’t have any orders across all the months and year as

SELECT *
FROM Product a
LEFT OUTER JOIN (
	SELECT ProductId
	FROM OrderDetail
	GROUP BY ProductId
) b on b.ProductId = a.Id
WHERE b.ProductId is null

--Get the list of employees who processed orders for the product chai

SELECT *
FROM Employee e
JOIN (
	SELECT o.EmployeeId
	FROM [Order] o
	JOIN OrderDetail od on od.OrderId = o.Id
		JOIN Product p on p.Id = od.ProductId and p.ProductName = 'Chai'
	GROUP BY o.EmployeeId
) b on b.EmployeeId = e.Id

--Get the list of employees and the count of orders they processed in the month of march across all years

SELECT Max(e.LastName) LastName
	,Max(e.FirstName) FirstName
	,Count(o.Id) CountOfOrders
	--,Count(Case when substr(o.OrderDate,1,4) = '2012' then o.Id end) as [2012 Orders]
	--,Count(Case when substr(o.OrderDate,1,4) = '2013' then o.Id end) as [2013 Orders]
	--,Count(Case when substr(o.OrderDate,1,4) = '2014' then o.Id end) as [2014 Orders]
	--,Count(Case when substr(o.OrderDate,1,4) = '2015' then o.Id end) as [2015 Orders]
	--,Count(Case when substr(o.OrderDate,1,4) = '2016' then o.Id end) as [2016 Orders]
FROM [Order] o
JOIN Employee e on e.Id = o.EmployeeId
WHERE substr(o.OrderDate,6,2) = '03'
GROUP BY o.EmployeeId
ORDER BY 3 desc

--Get the list of employees who processed the orders that belong to the city in which they live

SELECT e.LastName
	,e.FirstName
FROM [Order] o
JOIN Employee e on e.Id = o.EmployeeId and e.City = o.ShipCity
GROUP BY e.LastName
	,e.FirstName

--Get the list of employees who processed the orders that don’t belong to the city in which they live

SELECT e.LastName
	,e.FirstName
FROM [Order] o
JOIN Employee e on e.Id = o.EmployeeId and e.City <> o.ShipCity
GROUP BY e.LastName
	,e.FirstName

--Get the shipping companies that processed ordersfor the category Seafood

SELECT max(S.CompanyName) CompanyName
FROM [Order] o
JOIN OrderDetail od on od.OrderId = o.Id
	JOIN Product p on p.Id = od.ProductId
		JOIN Category c on c.Id = p.CategoryId and c.CategoryName = 'Seafood'
JOIN Shipper s on s.Id = o.ShipVia
GROUP BY s.Id

--Get the category name and count of orders processed by employees in the USA

SELECT CategoryName
	,Count(Id) as Orders
FROM (
		SELECT c.CategoryName 
			,o.Id
		FROM [Order] o
		JOIN OrderDetail od on od.OrderId = o.Id
			JOIN Product p on p.Id = od.ProductId
				JOIN Category c on c.Id = p.CategoryId 
		JOIN Employee e on e.Id = o.EmployeeId and e.Country = 'USA'
		GROUP BY c.CategoryName
			,o.Id
)










	