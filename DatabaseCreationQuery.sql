--DATABASE CREATION; Project DataWarehouse
CREATE DATABASE PDW
GO

USE PDW
GO

--DIMENSION CREATION
--Customer dimension table: holds customer information, where CustomerID is the primary key
CREATE TABLE DimCustomer
(
CustomerID int primary key identity,
CustomerAltID varchar(10) not null,
CustomerName varchar(50),
Gender varchar(20)
)
GO

--Customer dimension- sample values:
INSERT INTO DimCustomer(CustomerAltID, CustomerName, Gender)values
('IMI-001','Nadiya Anderson','F'),
('IMI-002','Denise Stapley','F'),
('IMI-003','Yul Kwon','M'),
('IMI-004','Benjamin Wade','M'),
('IMI-005','Tyson Apostol','M');
GO

--Product dimension table: holds product information without Sub-/Category, where ProductKey is the primary key
CREATE TABLE DimProduct
(
ProductKey int primary key identity,
ProductAltKey varchar(10)not null,
ProductName varchar(100),
ProductActualCost money,
ProductSalesCost money
)
GO

--Product dimension- sample values:
INSERT INTO DimProduct(ProductAltKey,ProductName, ProductActualCost, ProductSalesCost)values
('ITM-001','Wheat Floor 1kg',2.10,3.10),
('ITM-002','Rice Grains 1kg',0.40,1.40),
('ITM-003','SunFlower Oil 1 ltr',10,14),
('ITM-004','Palmolive Soap',1.85,2.85),
('ITM-005','Fab Ultra Washing Powder 1kg',3.5,7);
GO

--Store dimension table: holds related stores information, where StoreID is the primary key
CREATE TABLE DimStores
(
StoreID int primary key identity,
StoreAltID varchar(10)not null,
StoreName varchar(100),
StoreLocation varchar(100),
City varchar(100),
State varchar(100),
Country varchar(100)
)
GO

--Store dimension- sample values:
INSERT INTO DimStores(StoreAltID, StoreName, StoreLocation, City, State, Country)values
('LOC-A1','Coles','Hawthorn','Melbourne','Victoria','Australia'),
('LOC-A2','Coles','Kings Meadows','Launceston','Tasmania','Australia'),
('LOC-A3','Coles','Toowong','Brisbane','Queensland','Australia');
GO

--Create Dimension Sales Person table which will hold details related stores available across various places.
--SalesPerson dimension table: holds Employee information, where SalesPersonID is the primary key
CREATE TABLE DimSalesPerson
(
SalesPersonID int primary key identity,
SalesPersonAltID varchar(10)not null,
SalesPersonName varchar(100),
StoreID int,
City varchar(100),
State varchar(100),
Country varchar(100)
)
GO

--SalesPerson dimension- sample values:
INSERT INTO DimSalesPerson(SalesPersonAltID, SalesPersonName, StoreID, City, State, Country)values
('SP-DMSPR1','Rob',1,'Melbourne','Victoria','Australia'),
('SP-DMSPR2','Russell',1,'Melbourne','Victoria','Australia'),
('SP-DMSPR3','Ben',2,'Launceston','Tasmania','Australia'),
('SP-DMSPR4','Nick',2,'Launceston','Tasmania','Australia'),
('SP-DMSPR5','John',3,'Brisbane','Queensland','Australia'),
('SP-DMSPR6','Aras',3,'Brisbane','Queensland','Australia');
GO


--FACT TABLE CREATION
--Create Fact Table
CREATE TABLE FactProductSales
(
TransactionId bigint primary key identity,
SalesInvoiceNumber int not null,
SalesDateKey int,
SalesTimeKey int,
SalesTimeAltKey int,
StoreID int not null,
CustomerID int not null,
ProductID int not null,
SalesPersonID int not null,
Quantity float,
SalesTotalCost money,
ProductActualCost money,
Deviation float
)
GO


-- Add relation between fact table foreign keys to Primary keys of Dimensions
AlTER TABLE FactProductSales ADD CONSTRAINT
FK_StoreID FOREIGN KEY (StoreID)REFERENCES DimStores(StoreID);

AlTER TABLE FactProductSales ADD CONSTRAINT
FK_CustomerID FOREIGN KEY (CustomerID)REFERENCES Dimcustomer(CustomerID);

AlTER TABLE FactProductSales ADD CONSTRAINT
FK_ProductKey FOREIGN KEY (ProductID)REFERENCES Dimproduct(ProductKey);

AlTER TABLE FactProductSales ADD CONSTRAINT
FK_SalesPersonID FOREIGN KEY (SalesPersonID)REFERENCES Dimsalesperson(SalesPersonID);
GO

/*
AlTER TABLE FactProductSales ADD CONSTRAINT
FK_SalesDateKey FOREIGN KEY (SalesDateKey)REFERENCES DimDate(DateKey);
GO


AlTER TABLE FactProductSales ADD CONSTRAINT
FK_SalesTimeKey FOREIGN KEY (SalesTimeKey)REFERENCES DimDate(TimeKey);
GO
*/

INSERT INTO FactProductSales(SalesInvoiceNumber,SalesDateKey,
SalesTimeKey,SalesTimeAltKey,StoreID,CustomerID,ProductID,
SalesPersonID,Quantity,ProductActualCost,SalesTotalCost,Deviation)values
--1-jan-2013
--SalesInvoiceNumber,SalesDateKey,SalesTimeKey,SalesTimeAltKey,
--(StoreID,CustomerID,ProductID ,SalesPersonID,Quantity,ProductActualCost,SalesTotalCost,Deviation)
(1,20130101,44347,121907,1,1,1,1,2,11,13,2),
(1,20130101,44347,121907,1,1,2,1,1,22.50,24,1.5),
(1,20130101,44347,121907,1,1,3,1,1,42,43.5,1.5),

(2,20130101,44519,122159,1,2,3,1,1,42,43.5,1.5),
(2,20130101,44519,122159,1,2,4,1,3,54,60,6),

(3,20130101,52415,143335,1,3,2,2,2,11,13,2),
(3,20130101,52415,143335,1,3,3,2,1,42,43.5,1.5),
(3,20130101,52415,143335,1,3,4,2,3,54,60,6),
(3,20130101,52415,143335,1,3,5,2,1,135,139,4),
--2-jan-2013
--SalesInvoiceNumber,SalesDateKey,SalesTimeKey,SalesTimeAltKey,_
--(StoreID,CustomerID,ProductID ,SalesPersonID,Quantity,ProductActualCost,SalesTotalCost,Deviation)
(4,20130102,44347,121907,1,1,1,1,2,11,13,2),
(4,20130102,44347,121907,1,1,2,1,1,22.50,24,1.5),

(5,20130102,44519,122159,1,2,3,1,1,42,43.5,1.5),
(5,20130102,44519,122159,1,2,4,1,3,54,60,6),

(6,20130102,52415,143335,1,3,2,2,2,11,13,2),
(6,20130102,52415,143335,1,3,5,2,1,135,139,4),

(7,20130102,44347,121907,2,1,4,3,3,54,60,6),
(7,20130102,44347,121907,2,1,5,3,1,135,139,4),

--3-jan-2013
--SalesInvoiceNumber,SalesDateKey,SalesTimeKey,SalesTimeAltKey,StoreID,_
--CustomerID,ProductID ,SalesPersonID,Quantity,ProductActualCost,SalesTotalCost,Deviation)
(8,20130103,59326,162846,1,1,3,1,2,84,87,3),
(8,20130103,59326,162846,1,1,4,1,3,54,60,3),


(9,20130103,59349,162909,1,2,1,1,1,5.5,6.5,1),
(9,20130103,59349,162909,1,2,2,1,1,22.50,24,1.5),

(10,20130103,67390,184310,1,3,1,2,2,11,13,2),
(10,20130103,67390,184310,1,3,4,2,3,54,60,6),

(11,20130103,74877,204757,2,1,2,3,1,5.5,6.5,1),
(11,20130103,74877,204757,2,1,3,3,1,42,43.5,1.5)
GO


--ALTERING DETAILS OF THE FACT TABLE
--Change SalesDateKey from int to date data type
ALTER TABLE FactProductSales
ADD tempcol date
GO

UPDATE FactProductSales
SET tempcol='2013-01-01'
WHERE SalesDateKey=20130101;

UPDATE FactProductSales
SET tempcol='2013-01-02'
WHERE SalesDateKey=20130102;

UPDATE FactProductSales
SET tempcol='2013-01-03'
WHERE SalesDateKey=20130103;

ALTER TABLE FactProductSales
DROP COLUMN SalesDateKey;
--rename tempcol to SalesTimeAltKey, rearrange in Design tab.


--Change SalesTimeAltKey from int to time data type
ALTER TABLE FactProductSales
ADD tempcol time
GO

UPDATE FactProductSales
SET tempcol='12:19:07'
WHERE SalesTimeAltKey='121907';

UPDATE FactProductSales
SET tempcol='12:21:59'
WHERE SalesTimeAltKey='122159';

UPDATE FactProductSales
SET tempcol='14:33:35'
WHERE SalesTimeAltKey='143335';

UPDATE FactProductSales
SET tempcol='16:29:09'
WHERE SalesTimeAltKey='162909';

UPDATE FactProductSales
SET tempcol='18:43:10'
WHERE SalesTimeAltKey='184310';

UPDATE FactProductSales
SET tempcol='20:47:57'
WHERE SalesTimeAltKey='204757';

ALTER TABLE FactProductSales
DROP COLUMN SalesTimeAltKey;
--rename tempcol to SalesTimeAltKey, rearrange in Design tab.



--Query to join dimensions to Fact Table; create View for ease of access.
CREATE VIEW FactTable AS
SELECT TransactionId, SalesInvoiceNumber, SalesDateKey, SalesTimeKey, SalesTimeAltKey,
ds.StoreName, ds.StoreLocation, dc.CustomerName, dp.ProductName, dsp.SalesPersonName,
Quantity, SalesTotalCost, ft.ProductActualCost, Deviation
FROM PDW.dbo.FactProductSales ft
	INNER JOIN PDW.dbo.DimCustomer dc
	ON ft.CustomerID = dc.CustomerID
	INNER JOIN PDW.dbo.DimProduct dp
	ON ft.ProductID = dp.ProductKey
	INNER JOIN PDW.dbo.DimSalesPerson dsp
	ON ft.SalesPersonID = dsp.SalesPersonID
	INNER JOIN PDW.dbo.DimStores ds
	ON ft.StoreID = ds.StoreID;


--List of Customers who have spent the most in the selected Coles stores
SELECT SalesInvoiceNumber, SUM(SalesTotalCost) AS Total
FROM (SELECT DISTINCT SalesTotalCost, SalesInvoiceNumber FROM FactTable) as FactTable
GROUP BY SalesInvoiceNumber
ORDER BY Total DESC;

--SalesPerson who has totaled the most amount of money in the selected Coles stores
SELECT SalesPersonName, SUM(SalesTotalCost) AS Total
FROM (SELECT DISTINCT SalesTotalCost, SalesPersonName FROM FactTable) as FactTable
GROUP BY SalesPersonName
ORDER BY Total DESC;


SELECT SUM(SalesTotalCost - ProductActualCost) AS Profit
FROM (SELECT DISTINCT SalesTotalCost, ProductActualCost FROM FactTable) as FactTable
GROUP BY SalesTotalCost
ORDER BY Profit DESC;