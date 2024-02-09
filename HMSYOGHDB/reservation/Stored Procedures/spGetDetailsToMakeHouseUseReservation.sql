
CREATE PROCEDURE [reservation].[spGetDetailsToMakeHouseUseReservation] --10078,5
(
	@FolioNumber int,
	@LocationID int
)
AS
BEGIN
	DECLARE @ReservationID int;
	DECLARE @ReservationTypeID int;
	DECLARE @ReservationStatusID int;
	DECLARE @OtherTran int;
	
	SELECT @ReservationID = r.ReservationID
	,@ReservationTypeID = r.ReservationTypeID
	,@ReservationStatusID = r.ReservationStatusID
	FROM [reservation].[Reservation] r	
	WHERE r.FolioNumber = @FolioNumber AND r.LocationID = @LocationID

	SELECT @OtherTran = COUNT(gw.GuestID)
	FROM guest.GuestWallet gw
	WHERE gw.ReservationID = @ReservationID AND AccountTypeID <> 82

	IF(@ReservationID = 0 OR @ReservationID IS NULL)
	BEGIN
		SELECT -1 StatusID, 'Invalid Folio Number!' [Message];
		RETURN;
	END

	IF(@ReservationTypeID = 7)
	BEGIN
		SELECT -1 StatusID, 'This is a House Use reservation!' [Message];
		RETURN;
	END

	IF(@ReservationStatusID NOT IN(1,3))
	BEGIN
		SELECT -1 StatusID, 'Only ''Reserved'' or ''IN-House'' reservations can be changed into House Use!' [Message];
		RETURN;
	END

	IF(@OtherTran > 0)
	BEGIN
		SELECT -1 StatusID, 'This reservation can''t be changed into House Use! Because some transactions have already made for this reservation.' [Message];
		RETURN;
	END

	SELECT 1 StatusID, '' [Message];

	SELECT r.[ReservationID]
	,([Title] + ' ' + (SELECT dbo.fnPascalCase(FirstName)) + ' ' + (SELECT dbo.fnPascalCase(LastName))) [FullName]	
	,rm.RoomNo
	,rt.ReservationType
	FROM [reservation].[Reservation] r
	INNER JOIN reservation.ReservedRoom rr ON r.ReservationID = rr.ReservationID AND rr.IsActive = 1
	INNER JOIN room.Room rm ON rr.RoomID = rm.RoomID	
	INNER JOIN [guest].[Guest] g ON r.GuestID = g.GuestID
	INNER JOIN [contact].[Details] cd ON g.ContactID = cd.ContactID
	INNER JOIN [person].[Title] t ON cd.TitleID = t.TitleID
	INNER JOIN reservation.ReservationType rt ON r.ReservationTypeID = rt.ReservationTypeID	
	WHERE r.ReservationID = @ReservationID	
END
