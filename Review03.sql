use master
go
if exists(select name from master..sysdatabases where name = 'CarWorld')
drop database CarWorld
go
--EX01--
	CREATE DATABASE CarWorld
	go
	use CarWorld
	go
	alter database CarWorld
	add  filegroup Regions
--EX02--
	CREATE TABLE Brands (
		BrandID int IDENTITY(1,1) PRIMARY KEY Nonclustered,
		BrandName varchar(50) constraint UN_BrandName UNIQUE NONCLUSTERED,
		Description varchar(100) NULL
	)
	go
--EX03--
	CREATE TABLE Types (
    TypeCode varchar(15) PRIMARY KEY,
    TypeName varchar(50) UNIQUE,
    Description varchar(100) NULL
	)
	GO
--EX04--
	CREATE TABLE Cars (
		CarCode varchar(20) PRIMARY KEY,
		CarName varchar(50) UNIQUE,
		Brand int FOREIGN KEY REFERENCES Brands(BrandID),
		Type varchar(15) FOREIGN KEY REFERENCES Types(TypeCode),
		Price int CHECK (Price >= 0) DEFAULT 0,
		Description varchar(100) NULL
	)
	go
--EX05--
	-- Insert 5 records into the Brands table
	INSERT INTO Brands (BrandName, Description)
	VALUES ('Vinfast', 'A Vietnamese car brand'),
		   ('BMW', 'A German car brand'),
		   ('Toyota', 'A Japanese car brand'),
		   ('Ford', 'An American car brand'),
		   ('Mercedes-Benz', 'A German car brand')
		   go
	-- Insert 5 records into the Types table
	INSERT INTO Types (TypeCode, TypeName, Description)
	VALUES ('SEDAN', 'Sedan', 'A type of car with four doors and a separate trunk'),
		   ('SUV', 'SUV', 'A type of car with a high ground clearance and a spacious interior'),
		   ('HATCHBACK', 'Hatchback', 'A type of car with a rear door that opens upwards to provide access to the cargo area'),
		   ('COUPE', 'Coupe', 'A type of car with two doors and a sloping rear roofline'),
		   ('CONVERTIBLE', 'Convertible', 'A type of car with a retractable roof')
		   go
		-- Insert 5 records into the Cars table
	INSERT INTO Cars (CarCode, CarName, Brand, Type, Price, Description)
	VALUES ('CAR001', 'Vinfast Lux A2.0', 2, 'SEDAN', 50000, 'A luxury sedan from BMW'),
		   ('CAR002', 'BMW X5', 1, 'SUV', 60000, 'A luxury SUV from Vinfast'),
		   ('CAR003', 'Toyota Corolla', 3, 'SEDAN', 20000, 'A reliable sedan from Toyota'),
		   ('CAR004', 'Ford Mustang', 4, 'COUPE', 30000, 'A sporty coupe from Ford'),
		   ('CAR005', 'Mercedes-Benz S-Class', 5, 'SEDAN', 70000, 'A luxury sedan from Mercedes-Benz');
	go
	/*
	--test 
	select * from Cars
	select * from Types
	select * from Brands
	*/
--EX06--
	--execute sp_helpindex BrANDS
	create clustered index	IX_BrandName
	on	Brands(BrandName)
	with (online = on)
	--execute sp_helpindex BrANDS
	go
--EX07--
	CREATE VIEW vw_Cars
	AS
	SELECT c.CarCode, c.CarName, b.BrandName, t.TypeName, c.Price, c.Description
	FROM Cars c
	JOIN Brands b ON c.Brand = b.BrandID
	JOIN Types t ON c.Type = t.TypeCode
	WHERE b.BrandName = 'Vinfast' AND t.TypeName = 'SUV'
	/*
	--test
	GO
	select * from vw_Cars
	*/
	go
--EX08
	CREATE PROCEDURE sp_ListDevices
	@BrandName varchar(50)
	AS
	BEGIN
		SELECT c.CarCode, c.CarName, b.BrandName, t.TypeName, c.Price, c.Description
		FROM Cars c
		JOIN Brands b ON c.Brand = b.BrandID
		JOIN Types t ON c.Type = t.TypeCode
		WHERE b.BrandName = @BrandName;
	END
	/*
	--test
	EXEC sp_ListDevices @BrandName = 'BMW'
	*/
	go
--EX09
	CREATE TRIGGER trg_Cars_DeleteOnZeroPrice
	ON Cars
	FOR UPDATE
	AS
	BEGIN
		IF UPDATE(Price)
			BEGIN
				DELETE FROM Cars
				WHERE CarCode IN (SELECT CarCode FROM inserted WHERE Price = 0)
				PRINT 'Item has been deleted';
			END
	END
	go
	/*
	--test
	-- Insert a test record into the Cars table
	INSERT INTO Cars (CarCode, CarName, Brand, Type, Price, Description)
	VALUES ('CARTEST', 'Test Car', 1, 'SEDAN', 10000, 'A test car');
	go
	SELECT * FROM Cars WHERE CarCode = 'CARTEST'
	-- Update the price of the test record to 0
	UPDATE Cars
	SET Price = 0
	WHERE CarCode = 'CARTEST'
	go
	-- Check if the test record was deleted
	SELECT * FROM Cars WHERE CarCode = 'CARTEST'
	*/


