-- Create Users Table
CREATE TABLE Users (
    UserID SERIAL,
    FirstName VARCHAR(15) NOT NULL,
    LastName VARCHAR(15) NOT NULL,
    Email VARCHAR(30) NOT NULL,
    ContactNo BIGINT NOT NULL,
    Password VARCHAR(40) NOT NULL,
    CONSTRAINT PK_Users PRIMARY KEY(UserID),
    CONSTRAINT U_Email UNIQUE (Email),
    CONSTRAINT U_Contact UNIQUE (ContactNo)
);

-- Create Trains Table
CREATE TABLE Trains (
    TrainID SERIAL,
    TrainName VARCHAR(40) NOT NULL,
    RunsOn VARCHAR(10) NOT NULL,
    TotalSeats INT NOT NULL,
    StartTime TIME NOT NULL,
    CONSTRAINT TrainPK PRIMARY KEY(TrainID),
    CONSTRAINT U_TrainName UNIQUE (TrainName)
);

-- Create Routes Table
CREATE TABLE Routes (
    RouteID INT NOT NULL,
    TrainID INT NOT NULL,
    CurrentStation VARCHAR(20) NOT NULL,
    RemainingSeats INT NOT NULL,
    TimefromStart INT NOT NULL,
    CurrentDate DATE NOT NULL,
    CONSTRAINT RoutesPK PRIMARY KEY(RouteID, TrainID, CurrentStation),
    CONSTRAINT RoutesFKTrain FOREIGN KEY(TrainID) 
        REFERENCES Trains(TrainID) ON DELETE CASCADE
);

-- Create Tickets Table
CREATE TABLE Tickets (
    TicketID SERIAL,
    UserID INT NOT NULL,
    RouteID INT NOT NULL,
    TrainID INT NOT NULL,
    SourceStation VARCHAR(20) NOT NULL,
    DestinationStation VARCHAR(20) NOT NULL,
    Price INT NOT NULL,
    Email VARCHAR(30) NOT NULL,
    ContactNo BIGINT NOT NULL,
    NoOfPassenger INT NOT NULL CHECK (NoOfPassenger > 0),
    CONSTRAINT TicketsPK PRIMARY KEY(TicketID),
    CONSTRAINT TicketsFKRoutes FOREIGN KEY(RouteID, TrainID, SourceStation) 
        REFERENCES Routes(RouteID, TrainID, CurrentStation) ON DELETE CASCADE,
    CONSTRAINT TicketsFKUser FOREIGN KEY(UserID) 
        REFERENCES Users(UserID) ON DELETE CASCADE
);

-- Create Passengers Table
CREATE TABLE Passengers (
    PassengerID SERIAL,
    TicketID INT NOT NULL,
    Name VARCHAR(30) NOT NULL,
    Age INT NOT NULL,
    Gender VARCHAR(1) CHECK (Gender IN ('M', 'F', 'O')),
    CONSTRAINT PassengersPK PRIMARY KEY(PassengerID),
    CONSTRAINT PassengersFKTickets FOREIGN KEY(TicketID) 
        REFERENCES Tickets(TicketID) ON DELETE CASCADE
);

-- Create Admins Table
CREATE TABLE Admins (
    AdminID SERIAL,
    AdminEmail VARCHAR(30) NOT NULL,
    Password VARCHAR(40) NOT NULL,
    CONSTRAINT AdminPK PRIMARY KEY(AdminID)
);

-- Indexing
CREATE INDEX UsersEmailIndex ON Users (Email);

-- Insert Queries
INSERT INTO Users (FirstName, LastName, Email, ContactNo, Password) 
VALUES (?, ?, ?, ?, ?);

-- Retrieve User for Login
SELECT * FROM Users WHERE Email = ?;

-- Get All Trains
SELECT * FROM Trains;

-- Get All Bookings
SELECT * FROM Tickets;

-- Change Password
SELECT Password FROM Users WHERE UserID = ?;
UPDATE Users SET Password = ? WHERE UserID = ?;

-- Admin Login
SELECT * FROM Admins WHERE AdminEmail = ?;

-- Search Available Trains
SELECT DEPARTURE.TrainID, DEPARTURE.RouteID, DEPARTURE.CurrentStation AS Dept, 
       ARRIVAL.CurrentStation AS Arr, 
       to_char(DEPARTURE.CurrentDate, 'YYYY-MM-DD') AS DepartureDate, 
       to_char(ARRIVAL.CurrentDate, 'YYYY-MM-DD') AS ArrivalDate, 
       ARRIVAL.TimefromStart - DEPARTURE.TimefromStart AS Duration, 
       ARRIVAL.TimefromStart AS ArrivalTime, DEPARTURE.TimefromStart AS DepartureTime 
FROM Routes AS DEPARTURE 
INNER JOIN Routes AS ARRIVAL 
ON (DEPARTURE.RouteID = ARRIVAL.RouteID AND DEPARTURE.TrainID = ARRIVAL.TrainID) 
WHERE DEPARTURE.CurrentStation = ? AND ARRIVAL.CurrentStation = ? 
AND ARRIVAL.TimefromStart > DEPARTURE.TimefromStart AND DEPARTURE.CurrentDate = ?;

-- Get Train Details
SELECT * FROM Trains WHERE TrainID = ?;

-- Get Route Details
SELECT CURRENTSTATION, TIMEFROMSTART FROM Routes 
WHERE TRAINID = ? ORDER BY TIMEFROMSTART;

-- Delete Train
DELETE FROM Trains WHERE TrainID = ?;

-- Delete Ticket
DELETE FROM Tickets WHERE TicketID = ?;

-- Get User Bookings
SELECT * FROM Tickets WHERE UserID = ?;

-- Book Ticket
INSERT INTO Tickets (UserID, RouteID, TrainID, SourceStation, DestinationStation, Price, Email, ContactNo, NoOfPassenger) 
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?) RETURNING TicketID;
INSERT INTO Passengers (TicketID, Name, Age, Gender) VALUES (?, ?, ?, ?);
UPDATE Routes SET RemainingSeats = (RemainingSeats - ?) 
WHERE TimefromStart >= (SELECT TimefromStart FROM Routes WHERE CurrentStation = ? AND RouteID = ? AND TrainID = ?) 
AND TimefromStart < (SELECT TimefromStart FROM Routes WHERE CurrentStation = ? AND RouteID = ? AND TrainID = ?) 
AND RouteID = ? AND TrainID = ?;

-- Add Train
SELECT MAX(RouteID) FROM Routes;
INSERT INTO Trains (TrainName, RunsOn, TotalSeats, StartTime) 
VALUES (?, ?, ?, ?) RETURNING TrainID;

-- Insert sample data into Trains table
INSERT INTO Trains (TrainName, RunsOn, TotalSeats, StartTime) 
VALUES 

('Shatabdi Express', 'Mon,Wed,Fri', 300, '08:00:00'),
('Duronto Express', 'Tue,Thu,Sat', 400, '10:00:00'),
('Garib Rath', 'Daily', 350, '12:00:00'),
('Jan Shatabdi', 'Sun,Mon', 250, '14:00:00');

ALTER TABLE Users MODIFY Password VARCHAR(255);
SELECT * FROM Users;
