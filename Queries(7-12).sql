USE CompanyManagmentSystem
GO

ALTER TABLE Tasks 
ADD Deadline Date;

UPDATE Tasks
SET Deadline = 
    CASE
        WHEN TaskId = 1 THEN '2023-02-10'
        WHEN TaskId = 2 THEN '2023-02-15'
        WHEN TaskId = 3 THEN '2023-08-01'
        WHEN TaskId = 4 THEN '2024-02-24'
        WHEN TaskId = 5 THEN '2023-09-15'
        WHEN TaskId = 6 THEN '2024-01-20'
        WHEN TaskId = 7 THEN '2024-02-10'
        WHEN TaskId = 8 THEN '2023-01-31'
        WHEN TaskId = 9 THEN '2023-11-30'
        WHEN TaskId = 10 THEN '2024-03-01'
        WHEN TaskId = 11 THEN '2023-12-15'
        WHEN TaskId = 12 THEN '2024-03-21'
        WHEN TaskId = 13 THEN '2024-01-10'
    END;

 SELECT * FROM Tasks t;

--Identify which employees has the most tasks with non-closed statuses with failed deadlines.
   
SELECT e.EmployeeId,
    e.FullName,
    COUNT(TaskId) AS NumberOfTasks
FROM
    Employees e
    LEFT JOIN Tasks t
    ON e.EmployeeId = t.AssigneeId
WHERE t.CurrentStatus != 'Closed'
    AND t.Deadline IS NOT NULL AND
    t.Deadline < GETDATE()
GROUP BY e.EmployeeId,
e.FullName
ORDER BY COUNT(TaskId) DESC;
 
 -- Move forward deadline for non-closed tasks in 5 days.

UPDATE Tasks
SET Deadline = DATEADD(DAY, 5, Deadline)
WHERE CurrentStatus != 'Closed';

--For each project count how many there are tasks which were not started yet.

ALTER TABLE Tasks
ADD StartDate DATE;

UPDATE Tasks
SET StartDate = 
    CASE
        WHEN TaskId = 1 THEN '2023-02-01'
        WHEN TaskId = 2 THEN '2023-02-10'
        WHEN TaskId = 3 THEN '2023-07-01'
        WHEN TaskId = 4 THEN NULL
        WHEN TaskId = 5 THEN '2023-09-01'
        WHEN TaskId = 6 THEN '2023-11-01'
        WHEN TaskId = 7 THEN NULL
        WHEN TaskId = 8 THEN NULL
        WHEN TaskId = 9 THEN '2023-02-01'
        WHEN TaskId = 10 THEN '2023-03-01'
        WHEN TaskId = 11 THEN '2023-08-01'
        WHEN TaskId = 12 THEN '2023-10-13'
        WHEN TaskId = 13 THEN '2024-03-30'
        ELSE NULL
    END;
   

 SELECT
    p.ProjectId,
    p.ProjectName,
    COUNT(t.TaskId) AS TasksNotStarted
FROM
    Projects p
LEFT JOIN
    Tasks t ON p.ProjectId = t.ProjectId 
GROUP BY
    p.ProjectId,
    p.ProjectName,
    t.StartDate
 HAVING t.StartDate IS NULL OR t.StartDate > GETDATE();

--For each project which has all tasks marked as closed move status to closed. Close date for such project should match close date for the last accepted task.

UPDATE Projects
SET 
    State = 'Closed',
    CloseDate = (
        SELECT MAX(t.Deadline)
        FROM Tasks t
        WHERE t.ProjectId = Projects.ProjectId
        AND t.CurrentStatus = 'Accepted'
    )

WHERE ProjectId IN (
    SELECT p.ProjectId
    FROM Projects p
    INNER JOIN Tasks t ON p.ProjectId = t.ProjectId
    GROUP BY p.ProjectId
   HAVING COUNT(*) = COUNT(CASE WHEN t.CurrentStatus = 'Closed' THEN 1 ELSE NULL END)
);

--Determine employees across all projects which has not non-closed tasks assigned.

SELECT
    e.EmployeeId,
    e.FirstName,
    e.LastName,
    ep.ProjectId,
    p.ProjectName
FROM
    Employees e
JOIN
    EmployeeProjects ep ON e.EmployeeId = ep.EmployeeId
JOIN
    Projects p ON ep.ProjectId = p.ProjectId
LEFT JOIN
    Tasks t ON ep.EmployeeId = t.AssigneeId AND ep.ProjectId = t.ProjectId AND t.CurrentStatus = 'Closed'
WHERE
    t.TaskId IS NULL;

--Assign given project task (using task name as identifier) to an employee which has minimum tasks with open status.

DECLARE @TaskName VARCHAR(255) = 'DeploySoftwareUpdate';
DECLARE @ProjectId INT = 6;

WITH NumberOfOpenTasks AS (
    SELECT TOP 1 WITH TIES
        ep.EmployeeId,
        COUNT(t.TaskId) AS OpenTasks
    FROM
        EmployeeProjects ep
    LEFT JOIN
        Tasks t ON ep.EmployeeId = t.AssigneeId AND ep.ProjectId = t.ProjectId AND t.CurrentStatus = 'Open'
    WHERE
        ep.ProjectId = @ProjectId
    GROUP BY
        ep.EmployeeId
    ORDER BY
        OpenTasks ASC
)
UPDATE t
SET
    t.AssigneeId = ot.EmployeeId
FROM
    Tasks t
JOIN
    NumberOfOpenTasks ot ON 1 = 1
WHERE
    t.ProjectId = @ProjectId
    AND t.TaskName = @TaskName
    AND t.CurrentStatus = 'Open';



