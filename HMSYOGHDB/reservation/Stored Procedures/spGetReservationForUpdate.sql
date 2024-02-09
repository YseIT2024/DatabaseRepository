
CREATE Proc [reservation].[spGetReservationForUpdate] --2386,1
(	
	@ReservationID int,
	@LocationID int	
)
AS
BEGIN	
	SELECT r.[ReservationID]
	,r.[ReservationTypeID]
	,[ReservationModeID]
	,r.[ExpectedCheckIn]
	,r.[ExpectedCheckOut]	
	,r.[GuestID]
	,r.[Adults]
	,r.[Children]
	--,r.[ExtraAdults]
	,r.[Rooms]
	,r.[Nights]
	,r.[ReservationStatusID]
	,[Hold_TransactionModeID]	
	,ISNULL(g.GroupCode,'') [GroupCode]	
	,[FirstName]
	,[LastName]
	,[TitleID]
	,[Street]
	,[City]
	,[State]
	,[ZipCode]
	,[CountryID]	
	,[Email]
	,[PhoneNumber]	
	,Discount
	,r.CompanyID
	FROM [reservation].[Reservation] r
	INNER JOIN [reservation].[vwReservationDetails] vr ON r.ReservationID = vr.ReservationID
	INNER JOIN [guest].[Guest] g ON r.GuestID = g.GuestID
	WHERE r.ReservationID = @ReservationID AND r.LocationID = @LocationID	

	SELECT r.RoomID, r.RoomNo, rt.RoomTypeID, rt.RoomType, Adults, Children, ExtraAdults, rat.Rate, rat.RateID, 
	c.CurrencySymbol, SUM(rat.Rate) [Total]
	FROM reservation.Reservation re
	INNER JOIN reservation.ReservedRoom rr ON re.ReservationID = rr.ReservationID AND rr.IsActive = 1
	INNER JOIN reservation.RoomRate rat ON rr.ReservedRoomID = rat.ReservedRoomID AND rat.IsActive = 1 AND rat.IsVoid = 0
	INNER JOIN room.Room r ON rr.RoomID = r.RoomID	
	INNER JOIN room.RoomType rt ON r.RoomTypeID = rt.RoomTypeID
	INNER JOIN currency.Currency c ON rr.RateCurrencyID = c.CurrencyID
	WHERE re.ReservationID = @ReservationID 
	GROUP BY r.RoomID, r.RoomNo, rt.RoomTypeID, rt.RoomType, Adults, Children, ExtraAdults, rat.Rate, rat.RateID, c.CurrencySymbol
	
	SELECT	
	ISNULL((SELECT [Note] FROM [reservation].[Note] WHERE ReservationID = @ReservationID AND NoteTypeID = 1),'') [StaffNote]   	   
	,ISNULL((SELECT [Note] FROM [reservation].[Note] WHERE ReservationID = @ReservationID AND NoteTypeID = 3),'') [GuestNote]   	 
	,ISNULL((SELECT [Note] FROM [reservation].[Note] WHERE ReservationID = @ReservationID AND NoteTypeID = 4),'') [Remarks]
END




