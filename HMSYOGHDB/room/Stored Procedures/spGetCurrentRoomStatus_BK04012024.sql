
CREATE PROCEDURE [room].[spGetCurrentRoomStatus_BK04012024] --1
(
	@LocationID INT,
	@dtRoomStatus as [app].[dtID] ReadOnly 
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @CurrentDate INT = (SELECT [app].[fnGetCurrentDate]());
	DECLARE @Status INT = (SELECT COUNT(ID) FROM @dtRoomStatus);

	IF (@Status = 0)-----All Rooms based on location---------
		BEGIN
			DECLARE @Room Table(RoomID INT);

			DECLARE @Temp TABLE(RoomID INT, RoomNo INT, RoomTypeID INT,RoomType VARCHAR(50), RoomTypeDescription VARCHAR(500),
			PrimaryStatusID INT,  PrimaryStatus VARCHAR(20), SecondaryStatusID INT, SecondaryStatus VARCHAR(20),ReservationID INT, 
			Name VARCHAR(200), ExpectedCheckIn VARCHAR(30), CheckedIn VARCHAR(30), ExpectedCheckOut VARCHAR(30), RoomStatusHistoryID INT)

			INSERT INTO @Temp (RoomID, RoomNo, RoomTypeID, RoomType, RoomTypeDescription, PrimaryStatusID, PrimaryStatus, 
			SecondaryStatusID, SecondaryStatus,	ReservationID, [Name], ExpectedCheckIn, CheckedIn, ExpectedCheckOut, RoomStatusHistoryID)
			
			Select DISTINCT r.RoomID, r.RoomNo,r.SubCategoryID RoomTypeID,rt.Code RoomType,rt.Name RoomTypeDescription
			,CASE WHEN primaryStatus.RoomStatusID IS NULL THEN 1 Else roomStatus.PrimaryStatusID END as [PrimaryStatusID]
			,CASE WHEN primaryStatus.RoomStatusID IS NULL THEN 'Vacant' ELSE primaryStatus.RoomStatus END as [PrimaryStatus]
			,CASE WHEN secondaryStatus.RoomStatusID IS NULL THEN 0 ELSE roomStatus.SecondaryStatusID END [SecondaryStatusID]	 
			,CASE WHEN primaryStatus.RoomStatusID = 5 AND @CurrentDate = roomStatus.ToDateID AND secondaryStatus.RoomStatusID IS NULL THEN 'Check-Out' 
			      WHEN secondaryStatus.RoomStatusID IS NULL THEN '' ELSE secondaryStatus.RoomStatus END [SecondaryStatus]
			,ISNULL(roomStatus.ReservationID,0) ReservationID
			,CASE WHEN vwr.ReservationID IS NULL THEN '' ELSE vwr.FullName END as [Name]
			
			,CASE WHEN primaryStatus.RoomStatusID = 5 THEN FORMAT(vwr.ExpectedCheckIn,'dd-MMM-yyyy') ELSE '' END [ExpectedCheckIn]
			,CASE WHEN primaryStatus.RoomStatusID = 5 THEN FORMAT(vwr.ActualCheckIn,'dd-MMM-yyyy') ELSE '' END [CheckedIn]
			,CASE WHEN primaryStatus.RoomStatusID = 2 OR primaryStatus.RoomStatusID = 5 THEN FORMAT(vwr.ExpectedCheckOut,'dd-MMM-yyyy') ELSE '' END [ExpectedCheckOut]
			
			,ISNULL(roomStatus.RSHistoryID,0) [RoomStatusHistoryID]
			
			From [Products].[Room] r
			INNER JOIN [Products].[SubCategory] rt ON r.SubCategoryID = rt.SubCategoryID
			LEFT JOIN  [room].[vwTodayRoomStatusHistory] AS roomStatus ON r.RoomID = roomStatus.RoomID
			LEFT JOIN [reservation].[vwReservationDetails] vwr ON roomStatus.ReservationID = vwr.ReservationID
			LEFT JOIN [Products].[RoomStatus] primaryStatus ON roomStatus.PrimaryStatusID = primaryStatus.RoomStatusID
			LEFT JOIN [Products].[RoomStatus] secondaryStatus ON roomStatus.SecondaryStatusID = secondaryStatus.RoomStatusID
			WHERE r.LocationID = @LocationID AND r.IsActive = 1
			ORDER BY r.RoomNo,ISNULL(roomStatus.ReservationID,0)

			INSERT INTO @Room
			SELECT RoomID From @Temp Group by RoomID Having COUNT(RoomID) > 1

			DELETE FROM @Temp WHERE RoomID IN (Select RoomID FROM @Room) AND PrimaryStatusID IN (3,4);

			SELECT RoomID, RoomNo, RoomTypeID, RoomType, RoomTypeDescription, PrimaryStatusID, PrimaryStatus, SecondaryStatusID, SecondaryStatus, ReservationID, 
			[Name], ExpectedCheckIn, CheckedIn, ExpectedCheckOut, RoomStatusHistoryID 
			FROM @Temp
			ORDER BY RoomNo
		END
	ELSE--------Get RoomDetails based on Status---------------
		BEGIN
			DECLARE @Rooms TABLE(ID INT IDENTITY(1,1),RoomID INT,RoomNo INT,RoomTypeID INT,RoomType VARCHAR(50),RoomTypeDescription VARCHAR(50)
			,PrimaryStatusID INT,PrimaryStatus VARCHAR(50),SecondaryStatusID INT, SecondaryStatus VARCHAR(50),ReservationID INT,Name VARCHAR(100),
			ExpectedCheckIn VARCHAR(11),CheckedIn VARCHAR(11),ExpectedCheckOut VARCHAR(11),RoomStatusHistoryID INT,RoomStatusID INT)

			INSERT INTO @Rooms(RoomID,RoomNo,RoomTypeID,RoomType,RoomTypeDescription,PrimaryStatusID,PrimaryStatus,SecondaryStatusID,SecondaryStatus,ReservationID,[Name],
			ExpectedCheckIn ,CheckedIn ,ExpectedCheckOut,RoomStatusHistoryID,RoomStatusID)
			Select DISTINCT r.RoomID, r.RoomNo,r.SubCategoryID,rt.Code RoomType,rt.Description RoomTypeDescription
			,CASE WHEN primaryStatus.RoomStatusID IS NULL THEN 1 Else roomStatus.PrimaryStatusID END as [PrimaryStatusID]
			,CASE WHEN primaryStatus.RoomStatusID IS NULL THEN 'Vacant'  ELSE primaryStatus.RoomStatus END as [PrimaryStatus]
			,CASE WHEN secondaryStatus.RoomStatusID IS NULL THEN 0 ELSE roomStatus.SecondaryStatusID END [SecondaryStatusID] 
			,CASE  WHEN primaryStatus.RoomStatusID = 5 AND @CurrentDate = roomStatus.ToDateID AND secondaryStatus.RoomStatusID IS NULL THEN 'Check-Out'
			        WHEN secondaryStatus.RoomStatusID IS NULL THEN '' ELSE secondaryStatus.RoomStatus END [SecondaryStatus]
			,ISNULL(roomStatus.ReservationID,0) ReservationID
			,CASE WHEN vwr.ReservationID IS NULL THEN '' ELSE vwr.FullName END as [Name]
			,CASE WHEN primaryStatus.RoomStatusID = 4 THEN FORMAT(ExpectedCheckIn,'dd-MMM-yyyy') ELSE '' END [ExpectedCheckIn]
			,CASE WHEN primaryStatus.RoomStatusID = 5 THEN FORMAT(ActualCheckIn,'dd-MMM-yyyy') ELSE '' END [CheckedIn]
			,CASE WHEN primaryStatus.RoomStatusID = 2 OR primaryStatus.RoomStatusID = 5 THEN FORMAT(ExpectedCheckOut,'dd-MMM-yyyy') ELSE '' END [ExpectedCheckOut]
			,ISNULL(roomStatus.RSHistoryID,0) [RoomStatusHistoryID]
			,CASE WHEN primaryStatus.RoomStatusID = 5 AND @CurrentDate = roomStatus.ToDateID AND secondaryStatus.RoomStatusID IS NULL THEN 100
			         WHEN secondaryStatus.RoomStatusID IS NULL THEN (CASE WHEN primaryStatus.RoomStatusID IS NULL THEN 1 Else roomStatus.PrimaryStatusID END)
					        ELSE secondaryStatus.RoomStatusID END
			From [Products].[Room] r
			INNER JOIN [Products].[SubCategory] rt ON r.SubCategoryID = rt.SubCategoryID
			LEFT JOIN  [room].[vwTodayRoomStatusHistory] AS roomStatus ON r.RoomID = roomStatus.RoomID
			LEFT JOIN [reservation].[vwReservationDetails] vwr ON roomStatus.ReservationID = vwr.ReservationID
			LEFT JOIN [Products].[RoomStatus] primaryStatus ON roomStatus.PrimaryStatusID = primaryStatus.RoomStatusID
			LEFT JOIN [Products].[RoomStatus] secondaryStatus ON roomStatus.SecondaryStatusID = secondaryStatus.RoomStatusID				
			WHERE r.LocationID = @LocationID AND r.IsActive = 1
			ORDER BY r.RoomNo,ISNULL(roomStatus.ReservationID,0)
			
			SELECT RoomID,RoomNo,RoomTypeID,RoomType,RoomTypeDescription,PrimaryStatusID,PrimaryStatus,SecondaryStatusID,SecondaryStatus,ReservationID,[Name],
			ExpectedCheckIn ,CheckedIn ,ExpectedCheckOut,RoomStatusHistoryID
			FROM @Rooms WHERE RoomStatusID IN (SELECT ID FROM @dtRoomStatus)
			ORDER BY RoomNo
		END
END


