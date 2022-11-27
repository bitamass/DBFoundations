--*************************************************************************--
-- Title: Assignment06
-- Author: Bita Massoudi
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2022-11-21,Bmassoudi,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_Bmassoudi')
	 Begin 
	  Alter Database [Assignment06DB_Bmassoudi] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_Bmassoudi;
	 End
	Create Database Assignment06DB_Bmassoudi;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_Bmassoudi;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

Create View vCategories 
 WITH SCHEMABINDING
 AS 
  Select CategoryID, CategoryName 
  From dbo.Categories;
go

Create View vProducts 
 WITH SCHEMABINDING
 AS 
  Select ProductID, ProductName, CategoryID, UnitPrice 
  From dbo.Products;
go

Create View vInventories 
 WITH SCHEMABINDING
 AS 
  Select InventoryID, InventoryDate, EmployeeID, ProductID, Count 
  From dbo.Inventories;
go

Create View vEmployees 
 WITH SCHEMABINDING
 AS 
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
  From dbo.Employees;
go

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?



Grant Select On vCategories to Public;
Deny Select on Categories to Public;
go



Grant Select On vProducts to Public;
Deny Select on Products to Public;
Go


Grant Select On vEmployees to Public;
Deny Select on Employees to Public;
Go


Grant Select On vInventories to Public;
Deny Select On Inventories to Public;
go

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

Create or Alter View vProductsByCategories
as
Select TOP 100000000 
C.CategoryName, P.ProductName, P.UnitPrice
From vCategories as C
Inner Join vProducts as P
On C.CategoryID = P.CategoryID
Order By 1, 2, 3
Go

Select *From vProductsByCategories
Go

-- Here is an example of some rows selected from the view:
-- CategoryName ProductName       UnitPrice
-- Beverages    Chai              18.00
-- Beverages    Chang             19.00
-- Beverages    Chartreuse verte  18.00


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

Create or Alter View vInventoriesByProductsByDates
as
Select TOP 100000000 
P.ProductName, I.InventoryDate, I.count
From vProducts as P
Inner Join vInventories as I
On P.ProductID = I.ProductID
Order By 2, 1, 3
Go

Select *From vInventoriesByProductsByDates
Go 

-- Here is an example of some rows selected from the view:
-- ProductName	  InventoryDate	Count
-- Alice Mutton	  2017-01-01	  0
-- Alice Mutton	  2017-02-01	  10
-- Alice Mutton	  2017-03-01	  20
-- Aniseed Syrup	2017-01-01	  13
-- Aniseed Syrup	2017-02-01	  23
-- Aniseed Syrup	2017-03-01	  33


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

Create or Alter View vInventoriesByEmployeesByDates
as
Select Distinct TOP 100000000 
I.InventoryDate, [EmployeeName]= E.EmployeeFirstName + ' ' + E.EmployeeLastName 
From vInventories as I
Inner Join vEmployees as E
On I.EmployeeID = E.EmployeeID
Order By 1, 2
Go
Select *From vInventoriesByEmployeesByDates
Go


-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

Create or Alter View vInventoriesByProductsByCategories
as
Select TOP 10000 
C.CategoryName, P.ProductName, I.InventoryDate, I.[Count]
From vInventories as I
Inner Join vEmployees as E
On I. EmployeeID = E. EmployeeID
Inner Join vProducts as P
on I. ProductID = P.ProductID
Inner Join vCategories as C
On P.CategoryID = C.CategoryID
Order By 1, 2, 3, 4


-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- CategoryName	ProductName	InventoryDate	Count
-- Beverages	  Chai	      2017-01-01	  39
-- Beverages	  Chai	      2017-02-01	  49
-- Beverages	  Chai	      2017-03-01	  59
-- Beverages	  Chang	      2017-01-01	  17
-- Beverages	  Chang	      2017-02-01	  27
-- Beverages	  Chang	      2017-03-01	  37


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

Create or Alter View vInventoriesByProductsByEmployees
as
Select TOP 10000 
C.CategoryName, P.ProductName, I.InventoryDate, I.[Count], EmployeeName = E.EmployeeFirstName + ' ' + E.EmployeeLastName
From vInventories as I
Inner Join vEmployees as E
on I.EmployeeID = E.EmployeeID
Inner Join vProducts as P
on I.ProductID = P.ProductID
Inner Join vCategories as C
on P.CategoryID = C.CategoryID
Order By 3, 1, 2, 4


-- Here is an example of some rows selected from the view:
-- CategoryName	ProductName	        InventoryDate	Count	EmployeeName
-- Beverages	  Chai	              2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	              2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chartreuse verte	  2017-01-01	  69	  Steven Buchanan
-- Beverages	  Côte de Blaye	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Guaraná Fantástica	2017-01-01	  20	  Steven Buchanan
-- Beverages	  Ipoh Coffee	        2017-01-01	  17	  Steven Buchanan
-- Beverages	  Lakkalikööri	      2017-01-01	  57	  Steven Buchanan

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

Create or Alter View vInventoriesForChaiAndChangByEmployees
as
Select TOP 10000 
C.CategoryName, P.ProductName, I.InventoryDate, I.[Count], EmployeeName = E.EmployeeFirstName+ ' ' + E.EmployeeLastName
From vInventories as I
Inner Join vEmployees as E
on I.EmployeeID = E.EmployeeID
Inner Join vProducts as P
on I.ProductID = P.ProductID
Inner Join vCategories as C
on P.CategoryID = C.CategoryID
Where I.ProductID in (Select ProductID From vProducts Where ProductName in ('Chai', 'Chang'))
Order By 3, 1, 2, 4

-- Here are the rows selected from the view:

-- CategoryName	ProductName	InventoryDate	Count	EmployeeName
-- Beverages	  Chai	      2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chai	      2017-02-01	  49	  Robert King
-- Beverages	  Chang	      2017-02-01	  27	  Robert King
-- Beverages	  Chai	      2017-03-01	  59	  Anne Dodsworth
-- Beverages	  Chang	      2017-03-01	  37	  Anne Dodsworth


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

Create or Alter View vEmployeesByManager 
AS 
SELECT Top 100000
M.EmployeeFirstName + ' ' + M.EmployeeLastName as Manager,
E.EmployeeFirstName + ' ' + E.EmployeeLastName as Employee
FROM vEmployees as E 
Inner Join vEmployees as M
ON E.ManagerID=M.EmployeeID
ORDER BY 1, 2
GO
Select *From vEmployeesByManager 
Go

-- Here are teh rows selected from the view:
-- Manager	        Employee
-- Andrew Fuller	  Andrew Fuller
-- Andrew Fuller	  Janet Leverling
-- Andrew Fuller	  Laura Callahan
-- Andrew Fuller	  Margaret Peacock
-- Andrew Fuller	  Nancy Davolio
-- Andrew Fuller	  Steven Buchanan
-- Steven Buchanan	Anne Dodsworth
-- Steven Buchanan	Michael Suyama
-- Steven Buchanan	Robert King


-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.



Create or Alter View vInventoriesByProductsByCategoriesByEmployees 
 AS 
SELECT Top 100000
     [CategoryID]=C.CategoryID
	,[CategoryName]= C.CategoryName
	,[ProductID]=P.ProductID
	,[ProductName]=P.ProductName
	,[UnitPrice]=P.UnitPrice
	,[InventoryID]=I.InventoryID
	,[InventoryDate]=I.InventoryDate
	,[Count]=I.Count
	,[EmployeeID]=E.EmployeeID
	,[Employee] = E.EmployeeFirstName + ' ' + E.EmployeeLastName
	,[Manager]=M.EmployeeFirstName + ' ' + M.EmployeeLastName
FROM vCategories AS C
	JOIN vProducts AS P ON C.CategoryID=P.CategoryID
	JOIN vInventories AS I ON I.ProductID=P.ProductID
	JOIN vEmployees AS E ON I.EmployeeID=E.EmployeeID
	JOIN vEmployees AS M ON E.ManagerID=M.EmployeeID
ORDER BY 1,3,6,9
GO  
Select *From vInventoriesByProductsByCategoriesByEmployees
Go


-- Here is an example of some rows selected from the view:
-- CategoryID	  CategoryName	ProductID	ProductName	        UnitPrice	InventoryID	InventoryDate	Count	EmployeeID	Employee
-- 1	          Beverages	    1	        Chai	              18.00	    1	          2017-01-01	  39	  5	          Steven Buchanan
-- 1	          Beverages	    1	        Chai	              18.00	    78	        2017-02-01	  49	  7	          Robert King
-- 1	          Beverages	    1	        Chai	              18.00	    155	        2017-03-01	  59	  9	          Anne Dodsworth
-- 1	          Beverages	    2	        Chang	              19.00	    2	          2017-01-01	  17	  5	          Steven Buchanan
-- 1	          Beverages	    2	        Chang	              19.00	    79	        2017-02-01	  27	  7	          Robert King
-- 1	          Beverages	    2	        Chang	              19.00	    156	        2017-03-01	  37	  9	          Anne Dodsworth
-- 1	          Beverages	    24	      Guaraná Fantástica	4.50	    24	        2017-01-01	  20	  5	          Steven Buchanan
-- 1	          Beverages	    24	      Guaraná Fantástica	4.50	    101	        2017-02-01	  30	  7	          Robert King
-- 1	          Beverages	    24	      Guaraná Fantástica	4.50	    178	        2017-03-01	  40	  9	          Anne Dodsworth
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    34	        2017-01-01	  111	  5	          Steven Buchanan
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    111	        2017-02-01	  121	  7	          Robert King
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    188	        2017-03-01	  131	  9	          Anne Dodsworth


-- Test your Views (NOTE: You must change the names to match yours as needed!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/