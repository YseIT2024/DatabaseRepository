
CREATE PROCEDURE [reservation].[spGetCheckinReservationForModifyOrCancel]
(
	@FolioNumber int,
	@LocationID int
)
AS
BEGIN
	DECLARE @Status int = 0;
	DECLARE @Message varchar(300) = '';

	IF EXISTS(SELECT ReservationID FROM reservation.Reservation WHERE FolioNumber = @FolioNumber AND LocationID = @LocationID AND ReservationStatusID = 3)
		BEGIN -----Found-----
			SET @Status = 1;
		END
	ELSE IF EXISTS(SELECT ReservationID FROM reservation.Reservation WHERE FolioNumber = @FolioNumber AND LocationID = @LocationID AND ReservationStatusID <> 3)
		BEGIN -----Status Changed-----
			SET @Status = -1;
		END
	ELSE
		BEGIN ------ Not Exists-------
			SET @Status = 0;
		END

	Select @Status [Status], @Message [Message]

	SELECT r.[ReservationID]
	,([Title] + ' ' + (SELECT dbo.fnPascalCase(FirstName)) + ' ' + (SELECT dbo.fnPascalCase(LastName))) AS [FullName]
	,rm.RoomNo
	,r.ActualCheckIn
	,r.ExpectedCheckOut
	FROM [reservation].[Reservation] r
	INNER JOIN reservation.ReservedRoom rr ON r.ReservationID = rr.ReservationID AND rr.IsActive = 1
	INNER JOIN room.Room rm ON rr.RoomID = rm.RoomID
	INNER JOIN [guest].[Guest] g ON r.GuestID = g.GuestID
	INNER JOIN [contact].[Details] cd ON g.ContactID = cd.ContactID
	INNER JOIN [person].[Title] t ON cd.TitleID = t.TitleID
	INNER JOIN [company].[Company] com on r.CompanyID = com.CompanyID
	WHERE r.FolioNumber = @FolioNumber AND r.LocationID = @LocationID AND ReservationStatusID = 3
END

