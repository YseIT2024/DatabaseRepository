-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE Proc [room].[spGetHouseKeepingPageLoad]
(
  @LocationID INT,
  @RoomID INT 
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
  
	SELECT EmployeeID,(Title + ' ' + FirstName + CASE WHEN LEN(LastName) > 1 THEN ' ' + LastName ELSE '' END) EmployeeName
	FROM [person].[vwEmployeeDetails]
	WHERE LocationID = @LocationID	

	SELECT ToDoTypeID,ToDoType FROM [todo].[Type]

	SELECT PriorityID,Priority FROM [todo].[Priority]

	EXEC room.[spRoomDueDateTime] @RoomID
END











