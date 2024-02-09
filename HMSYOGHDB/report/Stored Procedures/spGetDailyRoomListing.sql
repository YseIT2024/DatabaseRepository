
CREATE PROCEDURE [report].[spGetDailyRoomListing] --5,'2021-03-22',1
(	
	@LocationID int,
	@Date datetime,
	@UserID int = null
)
AS
BEGIN	
	DECLARE @DateId INT = CONVERT(INT,FORMAT(@Date,'yyyyMMdd'));
	DECLARE @PrintedOn VARCHAR(20) = Format(GETDATE(),'dd-MMM-yyyy hh:mm tt'); 

	SELECT room.Room.RoomNo	
	,CASE WHEN failed.[Status] IS NOT NULL THEN failed.[Status] ELSE CONCAT(ISNULL(rev.[Status],'Vacant'),' For ',Format(@Date,'dddd, MMMM d, yyyy')) END ReservationStatus
	,ISNULL(rev.GuestName,'') GuestName
	,ISNULL(rev.Adults,'') Adult
	,ISNULL(rev.Children,'') Children
	,room.RoomType.RoomType
	,ISNULL(rev.CheckIn,'') CheckIn
	,ISNULL(rev.CheckOut,'') CheckOut		
	FROM room.ROOM 
	INNER JOIN room.RoomType ON  room.ROOM.RoomTypeID = room.RoomType.RoomTypeID  AND room.ROOM.LocationID = @LocationID AND room.ROOM.IsActive = 1
    LEFT JOIN 
		(
			SELECT room.Room.RoomNo, CASE WHEN re.ReservationStatusID = 1 THEN 'Reserved' WHEN re.ReservationStatusID = 2 THEN 'Cancelled' WHEN re.ReservationStatusID = 3 
			THEN 'In House' WHEN re.ReservationStatusID = 4 THEN 'Checked Out'  End [Status]
			,(FirstName + CASE WHEN LEN(LastName) > 1 THEN ' ' + LastName ELSE '' END) GuestName
			,re.Adults
			,re.Children,room.RoomType.RoomType
			,FORMAT(CAST(ISNULL(re.ActualCheckIn,re.ExpectedCheckIn) as date),'dd-MMM-yyyy') CheckIn
			,FORMAT(CAST(ISNULL(re.ActualCheckOut,re.ExpectedCheckOut) as date),'dd-MMM-yyyy') CheckOut					
			FROM reservation.ReservationStatus
			INNER JOIN reservation.Reservation re ON reservation.ReservationStatus.ReservationStatusID = re.ReservationStatusID AND re.LocationID = @LocationID
			INNER JOIN reservation.ReservedRoom rr ON re.ReservationID = rr.ReservationID
			RIGHT JOIN room.Room ON  rr.RoomID =  room.Room.RoomID
			INNER JOIN room.RoomType ON room.Room.RoomTypeID = room.RoomType.RoomTypeID
			INNER JOIN guest.Guest gg ON re.GuestID = gg.GuestID 
			INNER JOIN contact.Details d ON gg.ContactID = d.ContactID
			WHERE room.ROOM.IsActive=1 AND rr.IsActive=1 AND CONVERT(DATE,@Date) BETWEEN CONVERT(DATE,re.ExpectedCheckIn) AND 
			CONVERT(DATE,ISNULL(re.ActualCheckOut,re.ExpectedCheckOut))
		) rev ON room.ROOM.RoomNo = rev.RoomNo 
	LEFT JOIN 
		(
			SELECT r.RoomNo 
			,'Out Of Order For ' + Format(@Date,'dddd, MMMM d, yyyy') [Status]			
			FROM [room].[RoomStatusHistory] rsh
			INNER JOIN room.Room r ON rsh.RoomID = r.RoomID and r.LocationID = @locationId
			INNER JOIN room.RoomType ON r.RoomTypeID = room.RoomType.RoomTypeID
			INNER JOIN room.RoomStatus rs ON rsh.RoomStatusID = rs.RoomStatusID
			LEFT JOIN todo.ToDo td ON rsh.RSHistoryID = td.RSHistoryID 
			WHERE(@DateId BETWEEN rsh.FromDateID AND rsh.ToDateID) AND rsh.IsPrimaryStatus = 1 AND rsh.RoomStatusID = 4	AND (td.IsCompleted != 1 OR td.IsCompleted IS NULL) 
		)as failed ON room.ROOM.RoomNo = failed.RoomNo

	UNION ALL

	SELECT r.RoomNo 
	,'Vacant For ' + Format(@Date,'dddd, MMMM d, yyyy') ReservationStatus
	,'' GuestName
	,'' Adult
	,'' Children
	,room.RoomType.RoomType
	,'' CheckIn
	,'' CheckOut		
	FROM [room].[RoomStatusHistory] rsh
	INNER JOIN room.Room r ON rsh.RoomID = r.RoomID and r.LocationID = 1
	INNER JOIN room.RoomType ON r.RoomTypeID = room.RoomType.RoomTypeID
	INNER JOIN room.RoomStatus rs ON rsh.RoomStatusID = rs.RoomStatusID
	LEFT JOIN todo.ToDo td ON rsh.RSHistoryID = td.RSHistoryID 
	WHERE(@DateId BETWEEN rsh.FromDateID AND rsh.ToDateID) AND rsh.IsPrimaryStatus = 1 AND rsh.RoomStatusID=3
	AND (td.IsCompleted !=1 OR  td.IsCompleted IS NULL)	
	ORDER BY RoomNo

	SELECT	@PrintedOn PrintedOn

	-----Insert in Log Table -----------------
	EXEC [app].[spInsertActivityLog] 4, @LocationID , 'Daily Room Listing', @UserID
END
