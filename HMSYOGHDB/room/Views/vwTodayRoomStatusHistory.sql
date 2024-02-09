


CREATE VIEW [room].[vwTodayRoomStatusHistory]
AS
	SELECT primaryStatus.[RoomID]
	,r.RoomNo   
	,primaryStatus.[RoomStatusID] PrimaryStatusID
	,rs.RoomStatus PrimaryStatus
	,ISNULL(secondaryStatus.RoomStatusID,0) SecondaryStatusID
	,ISNULL(secondaryStatus.RoomStatus,'') SecondaryStatus	
	,primaryStatus.[FromDateID]
	,primaryStatus.[ToDateID]
	,primaryStatus.[ReservationID]
	,COALESCE(secondaryStatus.[RSHistoryID],primaryStatus.RSHistoryID) RSHistoryID
	FROM  [Products].[Room] r 
	INNER JOIN [Products].[RoomLogs] primaryStatus ON r.RoomID = primaryStatus.RoomID and r.RoomStatusID=primaryStatus.RoomStatusID
	INNER JOIN [Products].[RoomStatus] rs ON primaryStatus.RoomStatusID = rs.RoomStatusID
	--LEFT JOIN todo.ToDo td ON primaryStatus.RSHistoryID = td.RSHistoryID 
	LEFT JOIN
	(
		SELECT 
		rsh2.[RSHistoryID]
		,rsh2.[RoomID]		
		,rsh2.[RoomStatusID]
		,rs.RoomStatus				
		FROM [Products].[Room] r 
		INNER JOIN [Products].[RoomLogs] rsh2 ON r.RoomID = rsh2.RoomID
		INNER JOIN [Products].[RoomStatus] rs ON rsh2.RoomStatusID = rs.RoomStatusID 
		--INNER JOIN todo.ToDo td ON rsh2.RSHistoryID = td.RSHistoryID AND td.IsCompleted = 0		
		WHERE ((SELECT [app].[fnGetCurrentDate]()) BETWEEN rsh2.FromDateID AND rsh2.ToDateID) AND rsh2.IsPrimaryStatus = 0
	) secondaryStatus ON primaryStatus.RoomID = secondaryStatus.RoomID
	WHERE ((SELECT [app].[fnGetCurrentDate]()) BETWEEN primaryStatus.FromDateID AND primaryStatus.ToDateID) 
	AND primaryStatus.IsPrimaryStatus = 1 
	--AND (td.IsCompleted <> 1 OR  td.IsCompleted IS NULL)
	AND primaryStatus.RSHistoryID NOT IN 
	(
		SELECT rsh1.RSHistoryID 
		FROM [Products].[RoomLogs] rsh1 
		WHERE rsh1.ToDateID = (SELECT [app].[fnGetCurrentDate]()) AND rsh1.RoomStatusID = 2 AND rsh1.IsPrimaryStatus = 1
	)	
	-----------------------------------------------------------------------------------------------------------------------------------

	--SELECT primaryStatus.[RoomID]
	--,r.RoomNo   
	--,primaryStatus.[RoomStatusID] PrimaryStatusID
	--,rs.RoomStatus PrimaryStatus
	--,ISNULL(secondaryStatus.RoomStatusID,0) SecondaryStatusID
	--,ISNULL(secondaryStatus.RoomStatus,'') SecondaryStatus	
	--,primaryStatus.[FromDateID]
	--,primaryStatus.[ToDateID]
	--,primaryStatus.[ReservationID]
	--,COALESCE(secondaryStatus.[RSHistoryID],primaryStatus.RSHistoryID) RSHistoryID
	--FROM  [Products].[Room] r 
	--left JOIN [Products].[RoomLogs] primaryStatus ON r.RoomID = primaryStatus.RoomID and r.RoomStatusID=primaryStatus.RoomStatusID
	--INNER JOIN [Products].[RoomStatus] rs ON primaryStatus.RoomStatusID = rs.RoomStatusID
	----LEFT JOIN todo.ToDo td ON primaryStatus.RSHistoryID = td.RSHistoryID 
	--LEFT JOIN
	--(
	--	SELECT 
	--	rsh2.[RSHistoryID]
	--	,rsh2.[RoomID]		
	--	,rsh2.[RoomStatusID]
	--	,rs.RoomStatus				
	--	FROM [Products].[Room] r 
	--	INNER JOIN [Products].[RoomLogs] rsh2 ON r.RoomID = rsh2.RoomID
	--	INNER JOIN [Products].[RoomStatus] rs ON rsh2.RoomStatusID = rs.RoomStatusID
	--	--INNER JOIN todo.ToDo td ON rsh2.RSHistoryID = td.RSHistoryID AND td.IsCompleted = 0		
	--	WHERE ((SELECT [app].[fnGetCurrentDate]()) BETWEEN rsh2.FromDateID AND rsh2.ToDateID) AND rsh2.IsPrimaryStatus = 1
	--) secondaryStatus ON primaryStatus.RoomID = secondaryStatus.RoomID
	--WHERE ((SELECT [app].[fnGetCurrentDate]()) BETWEEN primaryStatus.FromDateID AND primaryStatus.ToDateID) 
	--AND primaryStatus.IsPrimaryStatus = 1 
	----AND (td.IsCompleted <> 1 OR  td.IsCompleted IS NULL)
	--AND primaryStatus.RSHistoryID NOT IN 
	--(
	--	SELECT rsh1.RSHistoryID 
	--	FROM [Products].[RoomLogs] rsh1 
	--	WHERE rsh1.ToDateID = (SELECT [app].[fnGetCurrentDate]()) AND rsh1.RoomStatusID = 2 AND rsh1.IsPrimaryStatus = 0
	--)	


