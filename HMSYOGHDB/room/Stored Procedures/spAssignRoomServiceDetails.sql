-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [room].[spAssignRoomServiceDetails]
(
  @LocationID INT,
  @RoomID INT,
  @IsHouseKeeping bit
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF(@IsHouseKeeping = 1)
	BEGIN
		SELECT EmployeeID,(Title + ' ' + FirstName + CASE WHEN LEN(LastName) > 1 THEN ' ' + LastName ELSE '' END) EmployeeName
		FROM [person].[vwEmployeeDetails]
		WHERE LocationID = @LocationID 
		AND DesignationID IN (10,11,12)
	END
	ELSE
	BEGIN
		SELECT EmployeeID,(Title + ' ' + FirstName + CASE WHEN LEN(LastName) > 1 THEN ' ' + LastName ELSE '' END) EmployeeName
		FROM [person].[vwEmployeeDetails]
		WHERE LocationID = @LocationID 
		
	END
	

	SELECT ToDoTypeID,ToDoType FROM [todo].[Type]

	SELECT PriorityID,Priority FROM [todo].[Priority]

	EXEC room.[spRoomDueDateTime] @RoomID
END










