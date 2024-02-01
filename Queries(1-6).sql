USE CompanyManagmentSystem
GO

--Retrieve a list of all roles in the company, which should include the number of employees for each of role assigned

SELECT
	r.RoleName,
	COUNT(e.EmployeeId) AS EmployeeCount
FROM
	Roles r
INNER JOIN EmployeeProjects ep ON
	r.RoleId = ep.RoleId
INNER JOIN Employees e ON
	ep.EmployeeId = e.EmployeeId 
GROUP BY
	r.RoleId,
	r.RoleName;

--Get roles which has no employees assigned

SELECT
	r.RoleName
FROM
	Roles r
LEFT JOIN EmployeeProjects ep ON
	r.RoleId = ep.RoleId
WHERE
	ep.EmployeeId IS NULL;

--Get projects list where every project has list of roles supplied with number of employees

SELECT
	p.ProjectName,
	r.RoleName,
	COUNT(ep.EmployeeId) AS NumberOfEmployees
FROM
	Projects p
INNER JOIN EmployeeProjects ep
ON
	p.ProjectId = ep.ProjectId
INNER JOIN Roles r 
ON
	ep.RoleId = r.RoleId
GROUP BY
	ProjectName,
	r.RoleName
ORDER BY
	ProjectName;

-- For every project count how many tasks there are assigned for every employee in average

WITH TaskSummary AS
(
SELECT
	p.ProjectId,
	p.ProjectName,
	e.EmployeeId,
	COUNT(TaskId) AS NumberOfTasks
FROM
	Projects p
INNER JOIN EmployeeProjects ep 
ON
	ep.ProjectId = p.ProjectId
INNER JOIN Employees e 
ON
	ep.EmployeeId = e.EmployeeId
LEFT JOIN Tasks t 
ON
	ep.EmployeeId = t.AssigneeId
	AND ep.ProjectId = t.ProjectId
GROUP BY
	p.ProjectId,
	p.ProjectName,
	e.EmployeeId) 

SELECT
	ts.ProjectId,
	ts.ProjectName,
	ts.EmployeeId,
	AVG(NumberOfTasks) OVER(PARTITION BY ts.ProjectId,
ts.EmployeeId) AS AverageTasks
FROM
	TaskSummary ts
ORDER BY
	ts.ProjectId,
	ts.EmployeeId;

--Determine duration for each project

SELECT
	ProjectId,
	DATEDIFF(day, CreationDate, CloseDate) AS DurationOfProject
FROM
	Projects p
WHERE CloseDate IS NOT NULL;

--Identify which employees has the lowest number tasks with non-closed statuses.

SELECT
	AssigneeId,
	COUNT(TaskId) AS NumberOfTasks
FROM
	Tasks t
WHERE
	CurrentStatus != 'Closed'
GROUP BY
	AssigneeId
ORDER BY
	COUNT(AssigneeId) ASC;


