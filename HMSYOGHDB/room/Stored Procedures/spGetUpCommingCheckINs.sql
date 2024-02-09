-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE Proc [room].[spGetUpCommingCheckINs]
(
	@LocationID INT
)
AS
BEGIN
	
		DECLARE @temp_ReservationIDs TABLE (ID INT);

		INSERT INTO @temp_ReservationIDs
		SELECT r.ReservationID
		FROM reservation.Reservation r
		WHERE r.[LocationID] = @LocationID 
		AND r.ReservationStatusID = 1 
		AND CAST(r.ExpectedCheckIn AS DATE) > CAST(GETDATE() AS DATE)	

		SELECT rd.ReservationID
		,r.RoomID
		,r.RoomNo
		,rt.RoomType
		,rt.Description	RoomTypeDescription			
		,CASE WHEN [ReservationStatusID] IN (3,4) THEN FORMAT([ActualCheckIn],'dd-MMM-yyyy') ELSE FORMAT([ExpectedCheckIn],'dd-MMM-yyyy') END [ExpectedCheckIn]
		,CASE WHEN [ReservationStatusID] = 4 THEN FORMAT([ActualCheckOut],'dd-MMM-yyyy') ELSE FORMAT([ExpectedCheckOut],'dd-MMM-yyyy') END [ExpectedCheckOut]			
		,[Title] +' '+ [FirstName] + (CASE When LEN([LastName]) > 0 THEN ' '+ [LastName] ELSE '' END) as [Name]			
		FROM [reservation].[vwReservationDetails] rd
		INNER JOIN @temp_ReservationIDs t ON rd.ReservationID = t.ID
		INNER JOIN reservation.ReservedRoom rr ON rr.ReservationID = t.ID
		INNER JOIN room.Room r ON rr.RoomID = r.RoomID
		INNER JOIN room.RoomType rt ON r.RoomTypeID = rt.RoomTypeID		
		WHERE rr.IsActive = 1
		ORDER BY CONVERT(DATE,[ExpectedCheckIn]),RoomNo
		
END











