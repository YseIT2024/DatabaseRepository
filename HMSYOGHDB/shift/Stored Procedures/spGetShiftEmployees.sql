-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [shift].[spGetShiftEmployees]
(
	@FromDate DATE,
	@ToDate DATE,
	@LocationID INT
)
AS
BEGIN
	
	SELECT e.[EmployeeID], e.[DesignationID]
	,CAST([EmployeeIDNumber] as varchar(10)) + ' - ' + cd.FirstName + ' ' + ISNULL(cd.LastName,'') + ' (' + d.Designation + ')' [EmployeeName]
	FROM [person].[Employee] e
	INNER JOIN [person].[EmployeeAndLocation] eal ON e.EmployeeID = eal.EmployeeID AND eal.LocationID = @LocationID
	INNER JOIN [person].[Designation] d ON e.DesignationID = d.DesignationID
	INNER JOIN [contact].[Details] cd ON e.ContactID = cd.ContactID
	WHERE e.IsActive = 1 AND e.DesignationID NOT IN (1,2) AND e.[EmployeeID] NOT IN (SELECT EmployeeID FROM shift.ShiftAllocation WHERE DateID BETWEEN CAST(FORMAT(@FromDate,'yyyyMMdd') as int) AND CAST(FORMAT(@ToDate,'yyyyMMdd') as int))
	ORDER BY d.Designation
END










