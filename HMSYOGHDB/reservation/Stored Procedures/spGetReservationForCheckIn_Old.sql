create PROCEDURE [reservation].[spGetReservationForCheckIn_Old] --622,1,1
(	
	@ReservationID int,
	@LocationID int,
	@DrawerID int 	
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Rate DECIMAL(18,5);
	DECLARE @RoomTypeID INT;
	DECLARE @Nights INT;
	DECLARE @RateCurrencyID INT;

	SELECT @RoomTypeID = r.RoomTypeID , @Nights = Nights, @RateCurrencyID = RateCurrencyID
	FROM reservation.Reservation rn
	 INNER JOIN reservation.ReservedRoom rr ON rn.ReservationID = rr.ReservationID
	INNER JOIN room.Room r ON rr.RoomID = r.RoomID
	INNER JOIN room.RoomType rt ON r.RoomTypeID = rt.RoomTypeID	
	WHERE rn.ReservationID = @ReservationID AND rr.IsActive = 1

	SELECT @Rate = [ExchangeRate]
	FROM currency.vwCurrentExchangeRate exr 
	WHERE exr.CurrencyID = @RateCurrencyID AND exr.DrawerID = @DrawerID

	SELECT v.[ReservationID]
	,v.[FolioNumber]
	,v.[GuestID] 
	,[ReservationStatusID]
	,FORMAT([ExpectedCheckIn],'dd-MMM-yyyy') AS [ExpectedCheckIn]
	,FORMAT([ExpectedCheckOut],'dd-MMM-yyyy') AS [ExpectedCheckOut]
	,[FirstName]
	,[Title] + ' ' + [FirstName] + (CASE When LEN([LastName]) > 0 THEN ' ' + [LastName] ELSE '' END) AS [Name]
	,v.[Adults]  
	,v.[Children]
	,v.[ExtraAdults] 
	,[Rooms]
	,[Nights]  
	,CASE WHEN kd.ReservationID IS NULL THEN 0.00 ELSE CAST(kd.KeyDeposit as decimal(18,2)) END [KeyDeposit] 
	,FORMAT([DateTime],'dd-MMM-yyyy') AS [DateTime]
	,[ReservationType]
	,[ReservationMode]	
	,[Hold]
	,[Discount]  
	,(CASE When LEN([Street]) > 0 THEN [Street] +', ' ELSE '' END) + (CASE When LEN([City]) > 0 THEN [City] +', ' ELSE '' END)
	+ (CASE When LEN([State]) > 0 THEN [State] +', ' ELSE '' END) + [CountryName] + (CASE When LEN([ZipCode]) > 0 THEN ', '+ [ZipCode]  ELSE '' END) as [Address]
	,[Email]
	,[PhoneNumber]
	,r.RoomNo
	,rt.RoomType	
	,@RateCurrencyID RateCurrencyID
	,CompanyID
	FROM [reservation].[vwReservationDetails] v	
	LEFT JOIN reservation.vwKeyDepositAndKeyRefund kd ON v.ReservationID = kd.ReservationID
	INNER JOIN reservation.ReservedRoom rr ON v.ReservationID = rr.ReservationID
	INNER JOIN room.Room r ON rr.RoomID = r.RoomID
	INNER JOIN room.RoomType rt ON r.RoomTypeID = rt.RoomTypeID	AND rr.IsActive = 1
	WHERE v.ReservationID = @ReservationID AND v.LocationID = @LocationID
	AND ReservationStatusID = 1

	EXEC [reservation].[spGetBookedRoomRate] @ReservationID

	SELECT CAST(fn.TotalAmount as decimal(18,2)) [TotalAmount]
	,CAST(fn.DiscountAmount as decimal(18,2))[DiscountAmount]
	,fn.Nights [Stay] 
	FROM [reservation].[fnGetReservationRoomBill](@ReservationID) fn

	SELECT CompanyID, CompanyName
	FROM company.Company
END
