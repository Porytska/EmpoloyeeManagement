-- Create Database

CREATE DATABASE CompanyManagmentSystem
GO

USE CompanyManagmentSystem
GO

--Create Schema

CREATE SCHEMA EmployeeSystem
GO

--Create tables with needed information 

CREATE TABLE Employees (
EmployeeId INT IDENTITY(1,1),
FirstName VARCHAR(100)  NOT NULL,
LastName VARCHAR(100) NOT NULL,
FullName AS CONCAT(FirstName, ' ', LastName),
PRIMARY KEY(EmployeeId)
);

CREATE TABLE Projects (
    ProjectId INT IDENTITY(1,1),
    ProjectName VARCHAR(255) NOT NULL,
    CreationDate DATE,
    CloseDate DATE,  
    State VARCHAR(100) CHECK(State IN ('Open', 'Closed')), 
    PRIMARY KEY(ProjectId)
);

CREATE TABLE Roles (
RoleId INT IDENTITY(1,1),
RoleName VARCHAR(100) NOT NULL,
PRIMARY KEY(RoleId)
 );

-- Associative table with EmployeeId, ProjectId, RoleId

CREATE TABLE EmployeeProjects (
    EmployeeProjectId INT IDENTITY(1,1),
    EmployeeId INT,
    ProjectId INT,
    RoleId INT,
    PRIMARY KEY(EmployeeProjectId),
    FOREIGN KEY(EmployeeId) REFERENCES Employees(EmployeeId),
    FOREIGN KEY(ProjectId) REFERENCES Projects(ProjectId),
    FOREIGN KEY(RoleId) REFERENCES Roles(RoleId)
);

--Table that include data on tasks and past modifications

CREATE TABLE Tasks (
    TaskId INT IDENTITY(1,1),
    TaskName VARCHAR(255) NOT NULL,
    AssigneeId INT NOT NULL,
    ProjectId INT NOT NULL,
    CurrentStatus VARCHAR(100) CHECK(CurrentStatus IN ('Open', 'Done', 'Need Work', 'Accepted', 'Closed')) NOT NULL,
    ChangeDate DATETIME,
    ResponsibleEmployeeId INT,
    PRIMARY KEY(TaskId),
    FOREIGN KEY(AssigneeId) REFERENCES Employees(EmployeeId),
    FOREIGN KEY(ProjectId) REFERENCES Projects(ProjectId),
    FOREIGN KEY(ResponsibleEmployeeId) REFERENCES Employees(EmployeeId)
);

-- Create trigger for updating ChangeDate and ResponsibleEmployeeId on status change

CREATE TRIGGER UpdateTaskStatus
ON Tasks
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(CurrentStatus)
    BEGIN
        UPDATE Tasks
        SET ChangeDate = GETDATE(),
            ResponsibleEmployeeId = INSERTED.AssigneeId
        FROM Tasks
        INNER JOIN INSERTED ON Tasks.TaskId = INSERTED.TaskId;
    END
END;

--Adding test data and forwarding modifications

INSERT INTO 
	Employees (FirstName, LastName)
VALUES 
  ('Emily', 'Smith'),
  ('Jason', 'Richmond'),
  ('Sarah', 'Davis'),
  ('Marcus', 'Taylor');

INSERT INTO 
	Projects (ProjectName, CreationDate, CloseDate, State)
VALUES ('CustomerPortal', '2023-01-01', '2023-02-01', 'Closed'),
    ('ExpenseTracker', '2023-03-10', '2023-04-10', 'Closed'),
    ('KnowledgeBaseUpgrade', '2023-07-01', '2023-08-01', 'Closed'),
    ('E-commercePlatform', '2023-08-12', '2024-01-30', 'Open'),
    ('NetworkSecurityEnhancement', '2023-10-10', '2024-02-10', 'Open'),
    ('CloudIntegrationProject', '2023-11-15', '2024-02-15', 'Open'),
    ('CRMSystemUpgrade', '2023-12-01', '2024-02-01', 'Open');

INSERT INTO
	Roles(RoleName)
VALUES ('Data Analyst'),
('Developer'),
('QA Engineer'),
('Team Lead'),
('Project Manager'),
('Srcum Master'),
('Database Administrator'),
('UI/UX Designer'),
('Software Engineer'),
('Tester'),
('HR Manager'),
('Recruiter');

INSERT INTO 
	EmployeeProjects(EmployeeId, ProjectId, RoleId)
VALUES (1,2,2),
(1,6,6),
(2,3,3),
(2,7,10),
(3,5,1),
(3,7,7),
(3,1,7),
(4,4,3),
(4,2,9),
(4,7,9),
(2,4,2),
(1,3,5),
(4,5,8),
(2,2,4),
(1,3,5),
(3,6,2);


INSERT INTO 
	Tasks (TaskName, AssigneeId, ProjectId, CurrentStatus)
VALUES
    ('UpdateUserInterface', 2, 6, 'Closed'),
    ('ImplementSecurityEnhancements', 1, 6, 'Closed'),
    ('TestDatabasePerformance', 4, 7, 'Open'), 
    ('DevelopNewFeature', 2, 3, 'Accepted'), 
    ('ReviewCodeQuality', 2, 2, 'Closed'),
    ('CreateDocumentation', 1, 6, 'Closed'), 
    ('BugFixing', 4, 7, 'Open'),
    ('DesignUserExperience', 4, 1, 'Closed'), 
    ('DataAnalysisReport', 2, 5, 'Accepted'), 
    ('OptimizeDatabaseQueries', 3, 6, 'Open'), 
    ('IntegrationTesting', 2, 4, 'Closed'), 
    ('ConductUserTraining', 1, 7, 'Need Work'), 
    ('DeploySoftwareUpdate', 1, 6, 'Open'); 
   


  



