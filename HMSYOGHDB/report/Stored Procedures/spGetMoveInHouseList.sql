
CREATE PROCEDURE [report].[spGetMoveInHouseList]--'2023-10-07','2023-10-07'
(	
	@FromDate date=null,
	@ToDate date=null,
	@UserID int=0,
	@LocationID int=0
)
AS
BEGIN TRY
BEGIN	
    SET @FromDate = COALESCE(@FromDate, DATEADD(DAY, -5, GETDATE()));
    SET @ToDate = COALESCE(@ToDate, GETDATE());
	 Select
	FORMAT(ISNULL(rrr.ModifiedDate, ''), 'dd-MMM-yyyy') AS ModifiedDate, 
	FORMAT(ISNULL(rrr.ModifiedDate, ''), 'HH:mm:ss tt') AS ModifiedTime,
    ISNULL(pr.RoomNo, '') AS ShiftedToRoom, 
    ISNULL(rrr.RoomID, '') AS ShiftedtoRoomID, 
    ISNULL(pr1.RoomNo, '') AS ShiftedFromRoom, 
    ISNULL(rrr.ShiftedRoomID, '') AS ShifFromRoomID, 
    ISNULL(rrs.Remarks, '') AS Remarks, 
    ISNULL(TL.[Title] + ' ' + CD.FirstName + ' ' + CD.LastName, '') AS [Name]
	from reservation.ReservedRoom rrr
	   INNER JOIN Products.room pr1 ON rrr.ShiftedRoomID=pr1.RoomID
	   INNER JOIN Products.room pr ON rrr.RoomID=pr.RoomID
	   INNER JOIN [reservation].[ReservationStatusLog] rrs ON  rrr.ReservationID=rrs.ReservationID
	   INNER JOIN reservation.Reservation rr ON rrr.ReservationID = rr.ReservationID
	   INNER JOIN guest.Guest gg ON rr.GuestID =gg.GuestID
	   INNER JOIN contact.Details CD ON  gg.ContactID=CD.ContactID
	   INNER JOIN person.Title TL ON CD.TitleID=TL.TitleID
	   INNER JOIN contact.Address CA ON CD.ContactID=CA.ContactID
	   WHERE CAST(rrr.ModifiedDate AS date) BETWEEN @FromDate AND @ToDate AND rrr.ShiftedRoomID IS not null
	   ORDER BY ModifiedDate DESC
	   
END
END TRY
BEGIN CATCH
    
        SELECT ERROR_MESSAGE() AS ErrorMessage;
    END CATCH