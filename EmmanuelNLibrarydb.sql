CREATE DATABASE EmmanuelNwambuonwoLibrary;
GO

USE EmmanuelNwambuonwoLibrary
GO

 
 CREATE TABLE Members (
    MemberId uniqueidentifier PRIMARY KEY DEFAULT NEWID(),
    UserName nvarchar(50) UNIQUE  NOT NULL ,
    Password_hash VARBINARY(MAX)  NOT NULL ,
    FirstName nvarchar(50)  NOT NULL ,
    MiddleName nvarchar(50)  NULL ,
    LastName nvarchar(50)  NOT NULL ,
    DOB date  NOT NULL ,
    Email nvarchar(100)  NULL CHECK 
     (Email LIKE '%_@_%._%') ,
    Telephone INT  NULL ,
    MemberStartDate DATE  NOT NULL ,
    MemberEndDate DATE  NULL ,
    MemberReactivationDate DATE  NULL ,
    AddressId uniqueidentifier  NULL);
	


CREATE TABLE Address (
    AddressId uniqueidentifier PRIMARY KEY DEFAULT NEWID(),
    AddressLine1 NVARCHAR(50)  NOT NULL ,
    AddressLine2 NVARCHAR(50)  NULL ,
    City NVARCHAR(50)  NOT NULL ,
    Postcode INT  NOT NULL,
	COUNTRY VARCHAR(50) NOT NULL);

CREATE TABLE ItemCatlogue (
    ItemId uniqueidentifier PRIMARY KEY DEFAULT NEWID(),
    ItemTitle NVARCHAR(200)  NOT NULL ,
    Author NVARCHAR(100)  NOT NULL ,
    DateAdded DATE  NOT NULL ,
    DatePublished DATE  NOT NULL ,
	PublicationYear AS YEAR(DatePublished),
    ISBN NVARCHAR(15)  NULL ,
    DateLost DATE   NULL ,
    DateRemoved DATE  NULL ,
    StatusID INT  NOT NULL ,
    ItemTypeId INT  NOT NULL );
	


CREATE TABLE ItemType (
    ItemTypeId INT IDENTITY(1,1) PRIMARY KEY,
    ItemTypeName VARCHAR(50));
	
	INSERT INTO ItemType
	(ItemTypeName) VALUES ('Book'),('Journal'),('DVD'),('OtherMedia')

CREATE TABLE Status (
    StatusId INT IDENTITY(5,1) PRIMARY KEY,
    StatusName VARCHAR (50));

	INSERT INTO STATUS 
	(StatusName) VALUES ('LoanedOut'),('Lost'),('Removed'),('Overdue'),('Available')

CREATE TABLE Loan (
    LoanId uniqueidentifier PRIMARY KEY DEFAULT NEWID(),
    DateTaken DATE NOT NULL,
    Datedue DATE NOT NULL,
    DateReturned DATE NULL,
    OverdueDays AS CASE WHEN Datedue <= GETDATE() THEN DATEDIFF(DAY, Datedue, GETDATE()) ELSE NULL END,
    ItemId uniqueidentifier NOT NULL,
    MemberId uniqueidentifier NOT NULL
);
	



CREATE TABLE OverdueFine (
    FineId uniqueidentifier PRIMARY KEY DEFAULT NEWID(),
    MemberId uniqueidentifier  NOT NULL ,
	LoanID uniqueidentifier,
    FineAmount SMALLMONEY);


CREATE TABLE Payment (
    PaymentID uniqueidentifier PRIMARY KEY DEFAULT NEWID(),
    AmountPaid SMALLMONEY  NOT NULL ,
    PaymentDateTime DATE  NOT NULL ,
    OutstandingBalance SMALLMONEY  NOT NULL ,
    ModeOfPayment VARCHAR(10)  NOT NULL ,
    MemberId uniqueidentifier  NOT NULL ,
    FineId uniqueidentifier  NOT NULL );



	 CREATE TABLE FormerMembers (
	 ArchiveId uniqueidentifier PRIMARY KEY DEFAULT NEWID(),
    MemberID uniqueidentifier NOT NULL ,
    UserName VARCHAR(50) UNIQUE  NOT NULL ,
    FirstName NVARCHAR(50)  NOT NULL ,
    MiddleName NVARCHAR(50)  NULL ,
    LastName NVARCHAR(50)  NOT NULL ,
    DOB DATE  NOT NULL ,
    Email NVARCHAR(100)  NULL CHECK 
     (Email LIKE '%_@_%._%') ,
    Telephone INT  NULL ,
    MemberStartDate DATE  NOT NULL ,
    MemberEndDate DATE  NULL ,
    MemberReactivationDate DATE  NULL ,
   );

ALTER TABLE Members ADD CONSTRAINT FK_Address FOREIGN KEY(AddressId)
REFERENCES Address (AddressId);


ALTER TABLE ItemCatlogue ADD CONSTRAINT FK_ItemType FOREIGN KEY(ItemTypeId)
REFERENCES ItemType (ItemTypeId);

ALTER TABLE ItemCatlogue ADD CONSTRAINT FK_Status FOREIGN KEY(StatusId)
REFERENCES Status (StatusId);






ALTER TABLE Loan ADD CONSTRAINT FK_ItemId FOREIGN KEY(ItemId)
REFERENCES ItemCatlogue (ItemId);


ALTER TABLE Loan ADD CONSTRAINT FK_MemberId FOREIGN KEY(MemberId)
REFERENCES Members (MemberID);



ALTER TABLE OverdueFine ADD CONSTRAINT FK_MemberId0 FOREIGN KEY(MemberId)
REFERENCES Members (MemberID);



ALTER TABLE Payment ADD CONSTRAINT FK_MemberId1 FOREIGN KEY(MemberId)
REFERENCES Members (MemberID);



ALTER TABLE Payment ADD CONSTRAINT FK_FineId FOREIGN KEY(FineId)
REFERENCES OverdueFine (FineId);



CREATE FUNCTION ItemSearch(@ItemName AS NVARCHAR(50))
RETURNS TABLE
AS
RETURN (
    SELECT ItemTitle, PublicationYear
    FROM (
        SELECT ItemTitle, PublicationYear, ROW_NUMBER() OVER (ORDER BY PublicationYear) as rn
        FROM ItemCatlogue
        WHERE ItemTitle = @ItemName
    ) AS subquery
    WHERE rn > 0
);


CREATE PROCEDURE GetFivedayDueItems
AS
BEGIN
   

    SELECT c.ItemTitle, l.Datedue --Itemtitle from catlogue & due date from loan tables
    FROM ItemCatlogue AS c
    INNER JOIN Loan AS l ON c.ItemID = l.ItemID
    WHERE l.DateReturned IS NULL
    AND DATEDIFF(day, GETDATE(), l.Datedue) <= 5; --takes items where the difference between today and duedate is less than 5
END

CREATE PROCEDURE InsertMember
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
	@DOB DATE,
    @UserName NVARCHAR(100),
    @Password_hash NVARCHAR(12),
    @Email NVARCHAR(100),
    @Telephone INT,
    @MemberStartDate DATE,
    @AddressLine1 NVARCHAR(100),
    @AddressLine2 NVARCHAR(100),
    @City NVARCHAR(50),
	@Country VARCHAR(50),
    @Postcode NVARCHAR(10)
AS
BEGIN
 BEGIN TRY
        BEGIN TRANSACTION;
		DECLARE @AddressId INT;
        -- Insert address data into the Address table
        INSERT INTO Address (AddressLine1, AddressLine2, City, Country, Postcode)
        VALUES (@AddressLine1, @AddressLine2, @City, @Country, @Postcode);

        -- Get the AddressId of the inserted row
        SET @AddressId = SCOPE_IDENTITY();

        -- Insert member data into the Members table
    

    INSERT INTO Members (FirstName, LastName, DOB, UserName, Password_hash, Email, Telephone, MemberStartDate)
    VALUES (@FirstName, @LastName, @DOB, @UserName, CONVERT(VARBINARY(MAX), @Password_hash), @Email, @Telephone, @MemberStartDate);

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    THROW;
END CATCH;
END;

EXEC InsertMember 
    @FirstName = 'Muhammadu',
    @LastName = 'Buhari',
	@DOB = '1947-12-17',
    @UserName = 'Presido',
    @Password_hash = Password_hash,
    @Email = 'Bubu@Asovilla.com',
    @Telephone = 00112345,
    @MemberStartDate = '2023-04-28',
    @AddressLine1 = 'Aso Rock',
    @AddressLine2 = 'Asokoro',
    @City = 'Abuja',
	@Country= 'Nigeria',
    @Postcode = 001;


CREATE PROCEDURE UpdateMember
    @MemberID INT,
    @FirstName NVARCHAR(50),
	@MiddleName NVARCHAR(50),
    @LastName VARCHAR(50),
    @Email VARCHAR(100),
	@DOB DATE,
    @AddressID INT,
    @AddressLine1 VARCHAR(100),
    @AddressLine2 VARCHAR(100),
    @City VARCHAR(50),
    @Postcode VARCHAR(20),
    @Country VARCHAR(50)
AS
BEGIN
    BEGIN TRANSACTION

    UPDATE Members
    SET FirstName = @FirstName,
		MiddleName=@MiddleName,
        LastName = @LastName,
        Email = @Email,
		DOB = @DOB,
        AddressID = @AddressID
    WHERE MemberID = @MemberID

    UPDATE Address
    SET AddressLine1 = @AddressLine1,
        AddressLine2 = @AddressLine2,
        City = @City,
        Postcode = @Postcode,
		Country = @Country
    WHERE AddressID = @AddressID

END;



CREATE VIEW LoanHistory AS
SELECT i.ItemTitle, i.Author, i.DateAdded, l.LoanId, l.DateTaken, l.DateDue, l.overdueDays,  o.FineAmount
FROM Loan l
JOIN ItemCatlogue i ON l.ItemID = i.ItemId
JOIN Members m ON l.memberID = m.memberID
JOIN OverdueFine o on o.memberId = m.memberId




 DROP TRIGGER IF EXISTS t_update_item_status;
 GO
 CREATE TRIGGER t_update_item_status
ON Loan
AFTER UPDATE
AS
BEGIN
    IF UPDATE(DateReturned)
    BEGIN
        UPDATE Items
        SET Status = 'Available'
        FROM Items i
        INNER JOIN inserted ins ON i.ItemID = ins.ItemID
        WHERE ins.DateReturned IS NOT NULL AND i.Status = 'On Loan'
    END
END

CREATE PROCEDURE InsertItemCatlogue
(
    @ItemTitle NVARCHAR(100),
    @Author NVARCHAR(100),
    @DateAdded DATE,
    @DatePublished DATE,
    @ISBN VARCHAR(50),
    @DateLost DATE,
    @DateRemoved DATE,
    @StatusId INT,
    @ItemTypeId INT
)
AS
BEGIN
    INSERT INTO itemcatalogue (ItemTitle, Author, DateAdded, DatePublished, ISBN, DateLost, DateRemoved, StatusId, ItemTypeId)
    VALUES (@ItemTitle, @Author, @DateAdded, @DatePublished, @ISBN, @DateLost, @DateRemoved, @StatusId, @ItemTypeId)
END

CREATE TRIGGER trg_set_item_on_loan
ON loan
AFTER INSERT
AS
BEGIN
    UPDATE itemcatalogue
    SET StatusId = 1 -- "On Loan" status
    FROM inserted
    WHERE itemcatalogue.ItemId = inserted.ItemId;
END;

CREATE PROCEDURE LoansCountThisday
@DATE DATE 
AS
BEGIN
SELECT COUNT(*) As 'Number of Loans taken'
FROM LOAN
WHERE DATETAKEN = @DATE
END



CREATE TRIGGER trg_UpdateFineAmount
ON dbo.loan
AFTER UPDATE
AS
BEGIN
    -- Check if the overdue days column has been updated
    IF UPDATE(DateReturned)
    BEGIN
        -- Get the member ID and loan ID for the updated row
        DECLARE @memberId INT, @loanId INT
        SELECT @memberId = memberId, @loanId = loanId FROM inserted
        
        -- Calculate the fine amount based on the updated overdue days
        DECLARE @fineAmount SMALLMONEY
        SELECT @fineAmount = 0.10 * i.overduedays
        FROM inserted i
        WHERE i.memberId = @memberId AND i.loanId = @loanId
        
        -- Update the fine amount in the overduefine table
        UPDATE overduefine
        SET fineAmount = @fineAmount
        WHERE memberId = @memberId 
    END
END


DROP TRIGGER IF EXISTS t_member_delete_archive;
GO
CREATE TRIGGER t_member_delete_archive ON Members
AFTER DELETE
AS BEGIN
 INSERT INTO FormerMembers
(MemberID, UserName, FirstName, MiddleName, LastName,
  DOB, Email,Telephone, MemberStartDate
  )
 SELECT
d.MemberId, d.UserName, d.FirstName, d.MiddleName, d.LastName,
  d.DOB, d.Email, d.Telephone, d.MemberStartDate
  
 FROM
 deleted d
 End;


 CREATE PROCEDURE DeleteMember
    @MemberID INT
AS
BEGIN
    -- Delete the member from the Members table
    DELETE FROM Members
    WHERE MemberID = @MemberID
    
  
END;

INSERT INTO Address (AddressLine1, City, Postcode, Country)
VALUES ('126 Ringlow Park Road', 'Manchester', '12965', 'Nigeria'),
       ('12 Yoruba Street', 'Sao Paulo', '67301921', 'Brazil'),
       ('13 Downing Street', 'London', '549321', 'United Kingdom')


DECLARE @AddressId INT
SET @AddressId = SCOPE_IDENTITY()

INSERT INTO Members (UserName, Password_hash, FirstName, MiddleName, LastName, DOB, Email, Telephone, MemberStartDate, AddressId)
VALUES 
('user11', CONVERT(varbinary(max), 'password130'), 'Barack', 'Hussein', 'Obama', '1980-01-01', 'barack@example.com', 123-456-7890, '2022-01-01', 2),
('user2', CONVERT(varbinary(max), 'password129'), 'Jane', NULL, 'Doe', '1985-01-01', NULL, 987-654-3210, '2022-01-01', 3),
('user3', CONVERT(varbinary(max), 'password128'), 'Bob', 'A', 'Smith', '1990-01-01', 'bobsmith@example.com', 555-555-5555, '2022-01-01', 4),
('user4', CONVERT(varbinary(max), 'password127'), 'Emmanuel', 'Chibuzor', 'Nwambuonwo', '1995-01-01', 'emmanuel@example.com', 111-111-1111, '2022-01-01', 5),
('user5', CONVERT(varbinary(max), 'password126'), 'Ayodeji', 'Ladipoe', 'Fagbemi', '2000-01-01', 'ayodeji@example.com', 222-222-2222, '2022-01-01', 6),
('user6', CONVERT(varbinary(max), 'password125'), 'Dubem', 'Amachi', 'Okonji', '2005-01-01', 'dubem@example.com', 333-333-3333, '2022-01-01', 7),
('user7', CONVERT(varbinary(max), 'password124'), 'Ogabu', 'Anyasi', 'David', '2010-01-01', 'david@example.com', 444-444-4444, '2022-01-01', 8),
('user8', CONVERT(varbinary(max), 'password123'), 'Samson', 'Fumnanya', 'Nwambuonwo', '2015-01-01', 'samson@example.com', 555-555-5555, '2022-01-01', 9),
('user9', CONVERT(varbinary(max), 'password122'), 'Bamidele', 'Olaore', 'Fagbemi', '2020-01-01', 'bamidele@example.com', 666-666-6666, '2022-01-01', 1),
('user10', CONVERT(varbinary(max), 'password121'), 'Titilola', 'Princess', 'Fagbemi', '2025-01-01', 'Titi@example.com', 777-777-7777, '2022-01-01', 11)





INSERT INTO ItemCatlogue (ItemTitle, Author, DateAdded, DatePublished, ISBN, DateLost, DateRemoved, StatusId, ItemTypeId)
VALUES 
('The Catcher in the Rye', 'J.D. Salinger', '2022-03-25', '1951', 9780316769174, NULL, NULL, 5, 1),
('To Kill a Mockingbird', 'Harper Lee', '2022-03-25', '1960', 9780061120084, NULL, NULL, 5, 1),
('1984', 'George Orwell', '2022-03-25', '1949', 9780451524935, NULL, NULL, 5, 1),
('Brave New World', 'Aldous Huxley', '2022-03-25', '1932', 9780060850524, NULL, NULL, 5, 1),
('Animal Farm', 'George Orwell', '2022-03-25', '1945', 9780452284241, NULL, NULL, 5, 1),
('The Great Gatsby', 'F. Scott Fitzgerald', '2022-03-25', '1925', 9780743273565, NULL, NULL, 5, 1),
('Lord of the Flies', 'William Golding', '2022-03-25', '1954', 9780399501487, NULL, NULL, 5, 1),
('Pride and Prejudice', 'Jane Austen', '2022-03-25', '1813', 9780141439518, NULL, NULL, 5, 1),
('Wuthering Heights', 'Emily Bronte', '2022-03-25', '1847', 9780141439556, NULL, NULL, 5, 1),
('The Adventures of Huckleberry Finn', 'Mark Twain', '2022-03-25', '1884', 9780141199009, NULL, NULL, 5, 1),
('The Divine Comedy', 'Dante Alighieri', '2022-03-25', '1320', 9780451208637, NULL, NULL, 5, 1),
('Moby-Dick', 'Herman Melville', '2022-03-25', '1851', 9780142437247, '2023-01-25', NULL, 2, 1),
('The Picture of Dorian Gray', 'Oscar Wilde', '2022-03-25', '1890', 9780141439570, NULL, NULL, 5, 1),
('The Bell Jar', 'Sylvia Plath', '2022-03-25', '1963', 9780062444479, NULL, '2023-03-29', 3, 1),
('The Sun Also Rises', 'Ernest Hemingway', '2022-03-25', '1926', 9780743297332, NULL, NULL, 5, 1);


