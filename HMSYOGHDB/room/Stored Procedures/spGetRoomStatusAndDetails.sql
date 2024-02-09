
CREATE PROCEDURE [room].[spGetRoomStatusAndDetails] ----1,2,0
(
	@LocationID int,
	@RoomID int,
	@ReservationID int = NULL
)	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @CurrentDate int = (SELECT [app].[fnGetCurrentDate]());
	
	IF (@ReservationID > 0)
		BEGIN
			SELECT DISTINCT r.RoomID, r.RoomNo, r.SubCategoryID, rt.Name RoomType, rt.[Description] RoomTypeDescription
			,CASE WHEN primaryStatus.RoomStatusID IS NULL THEN 1 Else roomStatus.PrimaryStatusID END as [PrimaryStatusID]
			,CASE WHEN primaryStatus.RoomStatusID IS NULL THEN 'Vacant' ELSE primaryStatus.RoomStatus END as [PrimaryStatus]
			,CASE WHEN secondaryStatus.RoomStatusID IS NULL THEN 0 ELSE roomStatus.SecondaryStatusID END [SecondaryStatusID]	 
			,CASE WHEN primaryStatus.RoomStatusID = 5 AND @CurrentDate = roomStatus.ToDateID AND secondaryStatus.RoomStatusID IS NULL THEN '' --'Check-Out'
				WHEN secondaryStatus.RoomStatusID IS NULL THEN '' ELSE secondaryStatus.RoomStatus END [SecondaryStatus]
			,ISNULL(roomStatus.ReservationID,0) ReservationID
			,CASE WHEN vwr.ReservationID IS NULL THEN '' ELSE vwr.FullName END as [Name]
			,CASE WHEN primaryStatus.RoomStatusID = 2 THEN FORMAT(ExpectedCheckIn,'dd-MMM-yyyy') ELSE '' END [ExpectedCheckIn]
			,CASE WHEN primaryStatus.RoomStatusID = 5 THEN FORMAT(ActualCheckIn,'dd-MMM-yyyy') ELSE '' END [CheckedIn]
			,CASE WHEN primaryStatus.RoomStatusID = 2 OR primaryStatus.RoomStatusID = 5 THEN FORMAT(ExpectedCheckOut,'dd-MMM-yyyy') ELSE '' END [ExpectedCheckOut]
			,ISNULL(roomStatus.RSHistoryID,0) [RoomStatusHistoryID]
			,(select top(1) LockNo from [Lock].[RoomInfo] where RoomId=R.RoomID) as 'LockNo'
			From [Products].[Room] r
			INNER JOIN [Products].[SubCategory] rt ON r.SubCategoryID = rt.SubCategoryID
			LEFT JOIN  [room].[vwTodayRoomStatusHistory] AS roomStatus ON r.RoomID = roomStatus.RoomID
			LEFT JOIN [reservation].[vwReservationDetails] vwr ON roomStatus.ReservationID = vwr.ReservationID
			LEFT JOIN [Products].[RoomStatus] primaryStatus ON roomStatus.PrimaryStatusID = primaryStatus.RoomStatusID
			LEFT JOIN [Products].[RoomStatus] secondaryStatus ON roomStatus.SecondaryStatusID = secondaryStatus.RoomStatusID
			WHERE r.LocationID = @LocationID AND r.RoomID = @RoomID  AND roomStatus.ReservationID = @ReservationID AND r.IsActive = 1
			ORDER BY r.RoomNo
		END
	ELSE
		BEGIN
			SELECT DISTINCT r.RoomID, r.RoomNo, r.SubCategoryID, rt.Name RoomType, rt.[Description] RoomTypeDescription
			,CASE WHEN primaryStatus.RoomStatusID IS NULL THEN 1 Else roomStatus.PrimaryStatusID END as [PrimaryStatusID]
			,CASE WHEN primaryStatus.RoomStatusID IS NULL THEN 'Vacant' ELSE primaryStatus.RoomStatus END as [PrimaryStatus]
			,CASE WHEN secondaryStatus.RoomStatusID IS NULL THEN 0 ELSE roomStatus.SecondaryStatusID END [SecondaryStatusID]	 
			,CASE WHEN primaryStatus.RoomStatusID = 5 AND @CurrentDate = roomStatus.ToDateID AND secondaryStatus.RoomStatusID IS NULL THEN '' --'Check-Out'
					WHEN secondaryStatus.RoomStatusID IS NULL THEN '' ELSE secondaryStatus.RoomStatus END [SecondaryStatus]
			,ISNULL(roomStatus.ReservationID,0) ReservationID			
			,CASE WHEN vwr.ReservationID IS NULL THEN '' ELSE vwr.FullName END as [Name]
			,CASE WHEN primaryStatus.RoomStatusID = 2 THEN FORMAT(ExpectedCheckIn,'dd-MMM-yyyy') ELSE '' END [ExpectedCheckIn]
			,CASE WHEN primaryStatus.RoomStatusID = 5 THEN FORMAT(ActualCheckIn,'dd-MMM-yyyy') ELSE '' END [CheckedIn]
			,CASE WHEN primaryStatus.RoomStatusID = 2 OR primaryStatus.RoomStatusID = 5 THEN FORMAT(ExpectedCheckOut,'dd-MMM-yyyy') ELSE '' END [ExpectedCheckOut]
			,ISNULL(roomStatus.RSHistoryID,0) [RoomStatusHistoryID]
			,(select top(1) LockNo from [Lock].[RoomInfo] where RoomId=R.RoomID) as 'LockNo'
			From [Products].[Room] r
			INNER JOIN [Products].[SubCategory] rt ON r.SubCategoryID = rt.SubCategoryID
			LEFT JOIN  [room].[vwTodayRoomStatusHistory] AS roomStatus ON r.RoomID = roomStatus.RoomID
			LEFT JOIN [reservation].[vwReservationDetails] vwr ON roomStatus.ReservationID = vwr.ReservationID
			LEFT JOIN [Products].[RoomStatus] primaryStatus ON roomStatus.PrimaryStatusID = primaryStatus.RoomStatusID
			LEFT JOIN [Products].[RoomStatus] secondaryStatus ON roomStatus.SecondaryStatusID = secondaryStatus.RoomStatusID
			WHERE r.LocationID = @LocationID AND r.RoomID = @RoomID  AND r.IsActive = 1 AND (roomStatus.ReservationID = 0 OR roomStatus.ReservationID IS NULL) 
			ORDER BY r.RoomNo
		END			
END


