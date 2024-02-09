
CREATE Proc [reservation].[spGetShrinkExtendedReservationDetails] --12601,1
(
	@FolioNumber INT,
	@LocationID INT	
)
AS
BEGIN	
	DECLARE @ReservationID int = (SELECT ReservationID FROM reservation.Reservation WHERE FolioNumber = @FolioNumber AND LocationID = @LocationID);

	IF (@ReservationID IS NULL OR @ReservationID = 0)
	BEGIN
		SELECT -1 [StatusID], 'Invalid Folio number.' [Message]
		RETURN;
	END

	--IF NOT EXISTS(SELECT r.ReservationID FROM reservation.Reservation r INNER JOIN reservation.ReservationStatusLog rsl ON r.ReservationID = rsl.ReservationID
	--AND rsl.ReservationStatusID = 6 WHERE r.ReservationID = @ReservationID AND LocationID = @LocationID)
	--BEGIN
	--	SELECT -2 [StatusID], 'This reservation can not shrink, because it has not been extended.' [Message]
	--	RETURN;
	--END

	SELECT 1 [StatusID], '' [Message]

	SELECT
	r.ReservationID
	,[Title] +' '+ [FirstName] + (CASE When LEN([LastName]) > 0 THEN ' '+ [LastName] ELSE '' END) as [Name]		
	,FORMAT(ISNULL(ActualCheckIn,ExpectedCheckIn),'dd-MMM-yyyy') [CheckIn] 
	,FORMAT(ExpectedCheckOut,'dd-MMM-yyyy') [CheckOut]	
	,rm.RoomNo
	,rt.RoomType
	,(SELECT TOP 1 RateCurrencyID FROM [reservation].[ReservedRoom] WHERE ReservationID = r.ReservationID) [RateCurrencyID]
	,r.Nights
	FROM [reservation].[Reservation] r 
	INNER JOIN reservation.ReservedRoom rr ON r.ReservationID = rr.ReservationID AND rr.IsActive = 1
	INNER JOIN room.Room rm ON rr.RoomID = rm.RoomID
	INNER JOIN room.RoomType rt ON rm.RoomTypeID = rt.RoomTypeID	
	INNER JOIN guest.Guest g On r.GuestID = g.GuestID
	INNER JOIN contact.Details cd ON g.ContactID = cd.ContactID
	INNER JOIN person.Title t ON cd.TitleID = t.TitleID
	WHERE r.ReservationID = @ReservationID AND r.LocationID = @LocationID

	SELECT	
	FORMAT(d.[Date],'dd-MMM-yyyy') [Date]
	,CAST([Rate] - (dsc.[Percentage] * [Rate] / 100) as decimal(18,2)) [Rate]	
	FROM reservation.ReservedRoom rr
	INNER JOIN [reservation].[RoomRate] rat ON rr.ReservedRoomID = rat.ReservedRoomID AND rr.IsActive = 1	
	INNER JOIN general.[Date] d ON rat.DateID = d.DateID
	INNER JOIN reservation.Discount dsc ON rat.DiscountID = dsc.DiscountID 
	WHERE rr.ReservationID = @ReservationID AND rat.IsActive = 1 
END

