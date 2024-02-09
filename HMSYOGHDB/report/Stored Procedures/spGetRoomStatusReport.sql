
CREATE Proc [report].[spGetRoomStatusReport]--1,0,'2019-11-13','2019-11-13'
(
	@RoomID INT,
	@StatusID INT,
	@FromDate DATETIME,
	@ToDate DATETIME
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @FromDateID INT = CONVERT(INT,FORMAT(@FromDate,'yyyyMMdd'))
	DECLARE @ToDateID INT=CONVERT(INT,FORMAT(@ToDate,'yyyyMMdd'))	

	IF (@StatusID > 0)
		BEGIN
			SELECT r.RoomNo, t.ToDoType [RoomService], FORMAT(EnteredOn, 'dd-MMM-yyyy hh:mm tt') [StartedOn]
			,CASE WHEN CompletedOn IS NULL THEN '' ELSE FORMAT(CompletedOn, 'dd-MMM-yyyy hh:mm tt') END [CompletedOn]
			,CASE WHEN td.AssignTo_EmployeeID IS NULL THEN ISNULL(td.AssignTo_Name,'') ELSE d.FirstName + ISNULL(d.LastName,'') END AssignedTo
			,[Description]
			,CASE WHEN IsCompleted = 0 THEN 'Pending' ELSE 'Completed' END IsCompleted
			FROM [room].[Room] r			
			INNER JOIN [room].[RoomStatusHistory] rsh ON r.RoomID = rsh.RoomID			
			INNER JOIN [todo].[ToDo] td  ON rsh.RSHistoryID = td.RSHistoryID 
			INNER JOIN [todo].[Type] t ON td.ToDoTypeID = t.ToDoTypeID
			LEFT JOIN [person].[Employee] e ON td.AssignTo_EmployeeID = e.EmployeeID
			LEFT JOIN [contact].[Details] d ON e.ContactID = d.ContactID
			WHERE r.RoomID = @RoomID AND td.ToDoTypeID = @StatusID AND (rsh.FromDateID BETWEEN @FromDateID AND @ToDateID)
		END
	ELSE
		BEGIN
			SELECT r.RoomNo, t.ToDoType [RoomService], FORMAT(EnteredOn, 'dd-MMM-yyyy hh:mm tt') [StartedOn]
			,CASE WHEN CompletedOn IS NULL THEN '' ELSE FORMAT(CompletedOn, 'dd-MMM-yyyy hh:mm tt') END [CompletedOn]
			,CASE WHEN td.AssignTo_EmployeeID IS NULL THEN ISNULL(td.AssignTo_Name,'') ELSE d.FirstName + ISNULL(d.LastName,'') END AssignedTo
			,[Description]
			,CASE WHEN IsCompleted = 0 THEN 'Pending' ELSE 'Completed' END IsCompleted 
			FROM [room].[Room] r			
			INNER JOIN [room].[RoomStatusHistory] rsh ON r.RoomID = rsh.RoomID	
			INNER JOIN [todo].[ToDo] td  ON rsh.RSHistoryID = td.RSHistoryID 
			INNER JOIN [todo].[Type] t ON td.ToDoTypeID = t.ToDoTypeID
			LEFT JOIN [person].[Employee] e ON td.AssignTo_EmployeeID = e.EmployeeID
			LEFT JOIN [contact].[Details] d ON e.ContactID = d.ContactID
			WHERE r.RoomID = @RoomID AND (rsh.FromDateID BETWEEN @FromDateID AND @ToDateID)
		END  
END


