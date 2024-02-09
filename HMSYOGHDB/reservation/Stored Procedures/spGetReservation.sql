
CREATE Proc [reservation].[spGetReservation] --64,1,1
(	
	@ReservationID int,
	@LocationID int,	
	@DrawerID int
)
AS
BEGIN
	

	DECLARE @RateEuro DECIMAL(18,5);	

	SELECT @RateEuro = [ExchangeRate] FROM currency.vwCurrentExchangeRate exr 
	WHERE exr.CurrencyID = 3 AND exr.DrawerID = @DrawerID

	SELECT rd.[ReservationID]
	,rd.FolioNumber	
	,rd.[GuestID]	
	,[ReservationStatusID]
	,FORMAT([ExpectedCheckIn],'dd-MMM-yyyy') [ExpectedCheckIn]
	,FORMAT([ExpectedCheckOut],'dd-MMM-yyyy') [ExpectedCheckOut]		
	,rd.[Adults] + rd.[ExtraAdults] [Adults]
	,rd.[Children][Children]
	,[Nights]	
	,CAST(CASE WHEN kd.ReservationID IS NULL THEN 0.00 ELSE kd.KeyDeposit END as decimal(18,2)) [KeyDeposit]	
	--,FORMAT([DateTime],'dd-MMM-yyyy') as [DateTime]
	,FORMAT([dbo].[GetDatetimeBasedonTimezone] ([DateTime]),'dd-MMM-yyyy') as [DateTime]
	,[Title] +' '+ [FirstName] + (CASE When LEN([LastName]) > 0 THEN ' '+ [LastName] ELSE '' END) as [Name]
	,[ReservationStatus]	
	,(CASE When LEN([Street]) > 0 THEN [Street] +', ' ELSE '' END) + (CASE When LEN([City]) > 0 THEN [City] +', ' ELSE '' END) 
	+ (CASE When LEN([State]) > 0 THEN [State] +', ' ELSE '' END)  + [CountryName] as [Address]
	,[Email]
	,[PhoneNumber]
	,r.RoomNo	
	FROM [reservation].[vwReservationDetails] rd	
	INNER JOIN [reservation].[ReservedRoom] rm ON rd.ReservationID = rm.ReservationID
	INNER JOIN [room].[Room] r ON rm.RoomID = r.RoomID
	LEFT JOIN reservation.vwKeyDepositAndKeyRefund kd ON rd.ReservationID = kd.ReservationID
	WHERE rd.ReservationID = @ReservationID
	ORDER BY rd.ReservationID DESC
	
END


select * from reservation.Reservation where reservationid in (865,864)










