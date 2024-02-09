CREATE PROCEDURE [reservation].[spGetReservationForCheckOut]  --6671, 1, 1
(	
	@ReservationID int,
	@LocationID int,
	@DrawerID int	
)
AS
BEGIN
	SET NOCOUNT ON;	

	DECLARE @ActualCheckIn datetime;
	DECLARE @ActualStay int;
	DECLARE @RateCurrencyID INT;

	
	 DECLARE @StandardMaxCheckOutTime Time(0)= (Select StandardCheckOutTimeCloseAt FROM [reservation].[StandardCheckInOutTime] )
	 declare @ReservationMaxCheckOutTime datetime=(select top 1 dateadd(MI, Convert(int,right(left(@StandardMaxCheckOutTime,5),2)),dateadd(HH,convert(int,left(@StandardMaxCheckOutTime,2)),Convert(datetime, FORMAT(ExpectedCheckOut,'yyyy-MM-dd')))) 
	 from reservation.Reservation with (nolock) where ReservationID =@ReservationID ORDER BY ExpectedCheckOut)
	
	SELECT @ActualCheckIn = ActualCheckIn, @RateCurrencyID = CurrencyID
	FROM reservation.Reservation
	WHERE ReservationID = @ReservationID AND LocationID = @LocationID AND ReservationStatusID = 3

	SET @ActualStay = (SELECT DATEDIFF(DAY, @ActualCheckIn, GETDATE()));

	IF(@ActualStay = 0)
	BEGIN
		SET @ActualStay = 1;
	END

	--select @TotalServiceRate = sum(ServiceRate) from [reservation].[ReservationServices] where ReservationID = 6058 and [Status] = 'A'
	
	SELECT Top 1 RS.[ReservationID]
	,RS.[FolioNumber]
	,RS.[GuestID] 
	,RS.[ReservationStatusID]
	,FORMAT([ActualCheckIn],'dd-MMM-yyyy') AS [ActualCheckIn]
	,FORMAT([ExpectedCheckOut],'dd-MMM-yyyy HH:mm:ss') AS [ExpectedCheckOut]
	--,CD.[FirstName]
	,TL.[Title] + ' ' + CD.[FirstName] + (CASE When LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END) AS [Name]
	,RS.[Adults]  
	,RS.[Children]
	,RD.[ExtraAdults] 
	,RD.[ExtraChildren]
	,RS.[Rooms]
	,RS.[Nights]  
	--,CASE WHEN kd.ReservationID IS NULL THEN 0.00 ELSE CAST(kd.KeyDeposit as decimal(18,2)) END [KeyDeposit] 
	,RT.[ReservationTypeID]
	,RT.[ReservationType]
	,RM.[ReservationMode]	
	,AD.[PhoneNumber]
	,(CASE When LEN(AD.[Street]) > 0 THEN Ad.[Street] +', ' ELSE '' END) + (CASE When LEN(AD.[City]) > 0 THEN AD.[City] +', ' ELSE '' END)
	+ (CASE When LEN(AD.[State]) > 0 THEN AD.[State] +', ' ELSE '' END) + CN.[CountryName] + (CASE When LEN(AD.[ZipCode]) > 0 THEN ', '+ AD.[ZipCode]  ELSE '' END) as [Address]
	,FORMAT([DateTime],'dd-MMM-yyyy') AS [DateTime]
	,RS.[AdditionalDiscount] as [Discount]  
	,TM.[TransactionMode] as [Hold]	
	,AD.[Email]
	
	,RS.AdditionalDiscountAmount
	,RS.TotalPayable
			--,r.RoomNo
			--,rt.RoomType	
	,@RateCurrencyID RateCurrencyID
	,CompanyID
	,fn.PayableAmount
	,fn.TotalPayment
	,fn.Balance
	,LC.CheckOutTime
	,@ReservationMaxCheckOutTime as StandardMaxCheckOutTime
	--FROM [reservation].[vwReservationDetails] v	
	FROM [reservation].[Reservation] RS
	inner join [reservation].[ReservationDetails] RD on RS.ReservationID = RD.ReservationID
	inner join [reservation].[ReservationType] RT on RS.ReservationTypeID = RT.ReservationTypeID
	inner join [reservation].[ReservationMode] RM on RS.ReservationModeID = RM.ReservationModeID
	inner join [account].[TransactionMode] TM on RS.Hold_TransactionModeID = TM.TransactionModeID

	inner join [guest].[Guest] GT on RS.GuestID = GT.GuestID
	inner join [contact].[Details] CD on GT.ContactID = CD.ContactID
	inner join [contact].[Address] AD on  CD.ContactID = AD.ContactID
	inner join [general].[Country] CN on AD.CountryID = CN.CountryID
	inner join [person].[Title] TL on CD.TitleID = TL.TitleID
	inner join [general].[Location] LC on RS.LocationID = LC.LocationID
	CROSS APPLY (SELECT * FROM [account].[fnGetReservationPayments_New](RS.ReservationID)) fn
	WHERE RS.ReservationID = @ReservationID AND RS.LocationID = @LocationID AND ReservationStatusID = 3 --AND rr.IsActive = 1
	
	--EXEC [reservation].[spGetBookedRoomRate] @ReservationID
	
	--SELECT DISTINCT c.CompanyID, CompanyName
	--FROM company.Company c
	--INNER JOIN company.CompanyAndContactPerson ccp ON c.CompanyID = ccp.CompanyID or c.CompanyID = 0
	--WHERE ccp.IsActive = 1 
	--ORDER BY CompanyID

	SELECT COALESCE(ggc.CompanyID, 1) AS CompanyID, COALESCE(ggc.CompanyName, 'Guest') AS CompanyName
		FROM [reservation].[Reservation] rr
		LEFT JOIN guest.GuestCompany ggc ON ggc.CompanyID = rr.CompanyTypeID
		WHERE rr.ReservationID = @ReservationID;
	--SELECT CompanyID, CompanyName
	--FROM [general].[Company]	

	select Distinct IT.ItemID, IT.ItemName,RD.Rooms 
	from [reservation].[Reservation] RS
	inner join [reservation].[ReservationDetails] RD on RS.ReservationID = RD.ReservationID
	inner join [Products].[Item] IT on RD.ItemID = IT.ItemID
	where RS.ReservationID= @ReservationID and RS.LocationID = @LocationID

	select NightDate,Rooms, LineTotal from [reservation].[ReservationDetails]
	where ReservationID = @ReservationID 

	select RS.TransId, SI.[Name] as ServiceName, RS.ServiceQty, RS.ServiceRate  from 
	[reservation].[ReservationServices] RS
	Inner join [service].[Item] SI on RS.ServiceId = SI.ItemID
	where RS.ReservationID = @ReservationID and RS.[Status] = 'A'

	select EM.[EmployeeID], CD.[FirstName] + ' '+ CD.[LastName] as [Name] from [general].[Employee] EM
	inner join [contact].[Details] CD on EM.ContactID = CD.ContactID
	inner join [general].[Designation] DS on CD.DesignationID = DS.DesignationID
	where  DS.[DesignationID] = 15 -- Bell Boy


		

	select SalesTypeID,SalesType from [reservation].[SalesTypes]
	--SELECT PayableAmount,TotalPayment,Balance  FROM [account].[fnGetReservationPayments](@ReservationID)
	



END
