-- ASSESSMENT 3: CREATE A DATABASE AND PERFORM MANIPULATION
-- Using Sequential Query Language

-- TASK 1: Create Database
USE master;
DROP DATABASE IF EXISTS LibraryDB;
CREATE DATABASE LibraryDB;
USE LibraryDB;
GO

-- TASK 2: Create Members Table
CREATE TABLE Members (
    MemberID  INT          NOT NULL IDENTITY(1,1),
    Name      VARCHAR(100) NOT NULL,
    Email     VARCHAR(100) NOT NULL,
    CONSTRAINT PK_Members PRIMARY KEY (MemberID)
);

INSERT INTO Members (Name, Email) VALUES
('Alice',  'alice@mail.com'),
('Bob',    'bob@mail.com'),
('Eve',    'eve@mail.com'),
('Cain',   'cain@mail.com'),
('Albert', 'albert@mail.com');

-- TASK 3: Create Books Table
CREATE TABLE Books (
    ISBN    VARCHAR(20)  NOT NULL,
    Title   VARCHAR(100) NOT NULL,
    Author  VARCHAR(100) NOT NULL,
    CONSTRAINT PK_Books PRIMARY KEY (ISBN)
);

INSERT INTO Books (ISBN, Title, Author) VALUES
('123648', 'Networking',          'White Black'),
('306090', 'Distributed Systems', 'Wright Left'),
('202040', 'Internet Security',   'Cain Tech'),
('305544', 'Data Principles',     'Eve Rose');

-- TASK 4: Create Borrowing Table
CREATE TABLE Borrowing (
    BorrowID    VARCHAR(10)  NOT NULL,
    MemberID    INT          NOT NULL,
    ISBN        VARCHAR(20)  NOT NULL,
    BorrowDate  DATE         NOT NULL,
    ReturnDate  DATE,
    CONSTRAINT PK_Borrowing PRIMARY KEY (BorrowID)
);

INSERT INTO Borrowing (BorrowID, MemberID, ISBN, BorrowDate, ReturnDate) VALUES
('B001', 1, '123648', '2026-05-04', '2026-05-14'),
('B002', 7, '669200', '2026-04-29', '2026-05-12'),
('B003', 2, '202040', '2026-05-05', '2026-05-21'),
('B004', 9, '101010', '2026-05-07', '2026-05-26');

-- TASK 5: Add Foreign Keys

ALTER TABLE Borrowing
ADD CONSTRAINT FK_Borrowing_Members
FOREIGN KEY (MemberID) REFERENCES Members(MemberID);

ALTER TABLE Borrowing
ADD CONSTRAINT FK_Borrowing_Books
FOREIGN KEY (ISBN) REFERENCES Books(ISBN);

-- TASK 6: Drop last record from Borrowing
DELETE FROM Borrowing
WHERE BorrowID = 'B004';

-- TASK 7: Add Password column to Members
ALTER TABLE Members
ADD [Password] VARCHAR(255);

-- TASK 8: Update Alice's email
UPDATE Members
SET Email = 'alice2026@mail.com'
WHERE MemberID = 1;

-- TASK 9: Delete Distributed Systems book
DELETE FROM Books
WHERE Title = 'Distributed Systems';

-- TASK 10: Inner Join
SELECT
    m.Name,
    b.Title,
    m.MemberID,
    b.ISBN
FROM Borrowing br
INNER JOIN Members m ON br.MemberID = m.MemberID
INNER JOIN Books b ON br.ISBN = b.ISBN;

-- TASK 11: Create View
GO
CREATE VIEW BorrowedBooks AS
SELECT
    m.Name,
    b.Title,
    m.MemberID,
    b.ISBN,
    br.BorrowDate,
    br.ReturnDate
FROM Borrowing br
INNER JOIN Members m ON br.MemberID = m.MemberID
INNER JOIN Books b ON br.ISBN = b.ISBN;
GO

-- TASK 12: Create Trigger
CREATE TRIGGER PreventMemberDeletion
ON Members
INSTEAD OF DELETE
AS
BEGIN
    RAISERROR('Deletion of members is not allowed.', 16, 1);
    ROLLBACK TRANSACTION;
END;
GO

-- TASK 13 & 14: Hash and store passwords for all members
EXEC sp_executesql N'UPDATE Members SET [Password] = HASHBYTES(''SHA2_256'', ''alice123'') WHERE MemberID = 1';
EXEC sp_executesql N'UPDATE Members SET [Password] = HASHBYTES(''SHA2_256'', ''bob123'') WHERE MemberID = 2';
EXEC sp_executesql N'UPDATE Members SET [Password] = HASHBYTES(''SHA2_256'', ''eve123'') WHERE MemberID = 3';
EXEC sp_executesql N'UPDATE Members SET [Password] = HASHBYTES(''SHA2_256'', ''cain123'') WHERE MemberID = 4';
EXEC sp_executesql N'UPDATE Members SET [Password] = HASHBYTES(''SHA2_256'', ''albert123'') WHERE MemberID = 5';

--Verifying the Passwords
SELECT
    MemberID,
    Name,
    CASE
        WHEN [Password] = HASHBYTES('SHA2_256', 'alice123')  THEN 'alice123'
        WHEN [Password] = HASHBYTES('SHA2_256', 'bob123')    THEN 'bob123'
        WHEN [Password] = HASHBYTES('SHA2_256', 'eve123')    THEN 'eve123'
        WHEN [Password] = HASHBYTES('SHA2_256', 'cain123')   THEN 'cain123'
        WHEN [Password] = HASHBYTES('SHA2_256', 'albert123') THEN 'albert123'
        ELSE 'Unknown'
    END AS [Password]
FROM Members;