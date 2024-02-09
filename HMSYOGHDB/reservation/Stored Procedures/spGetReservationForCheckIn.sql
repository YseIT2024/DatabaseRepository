CREATE PROCEDURE [reservation].[spGetReservationForCheckIn] --1137,1,1
(	
	@ReservationID int,
	@LocationID int,
	@DrawerID int 	
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Rate DECIMAL(18,5);
	--DECLARE @RoomTypeID INT;
	DECLARE @Nights INT;
	DECLARE @RateCurrencyID INT;
	Declare @ExpectedCheckInDate datetime, @ExpectedCheckOutDate datetime 
	DECLARE @StandardMinCheckInTime Time(0)= (Select StandardCheckInTimeCloseAt FROM [reservation].[StandardCheckInOutTime] )
	declare @ReservationMinCheckInTime datetime=(select top 1 dateadd(MI, Convert(int,right(left(@StandardMinCheckInTime,5),2)),dateadd(HH,convert(int,left(@StandardMinCheckInTime,2)),Convert(datetime,Nightdate))) 
	from reservation.ReservationDetails with (nolock) where ReservationID =@ReservationID order by NightDate)

	--set @ExpectedCheckInDate ='02-01-2023';
	--set @ExpectedCheckOutDate='03-01-2023';

	--SELECT @RoomTypeID = r.RoomTypeID , @Nights = Nights, @RateCurrencyID = RateCurrencyID
	--FROM reservation.Reservation rn
	-- INNER JOIN reservation.ReservedRoom rr ON rn.ReservationID = rr.ReservationID
	--INNER JOIN room.Room r ON rr.RoomID = r.RoomID
	--INNER JOIN room.RoomType rt ON r.RoomTypeID = rt.RoomTypeID	
	--WHERE rn.ReservationID = @ReservationID AND rr.IsActive = 1

	select @RateCurrencyID = CurrencyID, @ExpectedCheckInDate= ExpectedCheckIn, @ExpectedCheckOutDate = ExpectedCheckOut  from [reservation].[Reservation] where ReservationID = @ReservationID

	SELECT @Rate = [ExchangeRate]	FROM currency.vwCurrentExchangeRate exr 	WHERE exr.CurrencyID = @RateCurrencyID AND exr.DrawerID = @DrawerID

	SELECT top 1  v.[ReservationID]	,v.[FolioNumber]	,v.[GuestID] 	,[ReservationStatusID]
	,FORMAT([ExpectedCheckIn],'dd-MMM-yyyy') AS [ExpectedCheckIn]
	,FORMAT([ExpectedCheckOut],'dd-MMM-yyyy') AS [ExpectedCheckOut]
	,CD.[FirstName]	,TL.[Title] + ' ' + CD.[FirstName] + (CASE When LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END) AS [Name]
	,v.[Adults]  	,v.[Children]	,RD.[ExtraAdults] 	,RD.[ExtraChildren]	,v.[Rooms]	,v.[Nights]  
	--,CASE WHEN kd.ReservationID IS NULL THEN 0.00 ELSE CAST(kd.KeyDeposit as decimal(18,2)) END [KeyDeposit] 
	,FORMAT([DateTime],'dd-MMM-yyyy') AS [DateTime]	,RT.[ReservationType]	,RM.[ReservationMode]		,TM.[TransactionMode] as [Hold]
	,v.[AdditionalDiscount] as [Discount]  
	,(CASE When LEN(AD.[Street]) > 0 THEN Ad.[Street] +', ' ELSE '' END) + (CASE When LEN(AD.[City]) > 0 THEN AD.[City] +', ' ELSE '' END)
	+ (CASE When LEN(AD.[State]) > 0 THEN AD.[State] +', ' ELSE '' END) + CN.[CountryName] + (CASE When LEN(AD.[ZipCode]) > 0 THEN ', '+ AD.[ZipCode]  ELSE '' END) as [Address]
	,AD.[Email]	,AD.[PhoneNumber]	,v.AdditionalDiscountAmount	,v.TotalPayable
			--,r.RoomNo
			--,rt.RoomType	
	,@RateCurrencyID RateCurrencyID	,CompanyID,@ReservationMinCheckInTime as ReservationMinCheckInTime
	--FROM [reservation].[vwReservationDetails] v	
	FROM [reservation].[Reservation] v
	inner join [reservation].[ReservationDetails] RD on v.ReservationID = RD.ReservationID
	inner join [reservation].[ReservationType] RT on v.ReservationTypeID = RT.ReservationTypeID
	inner join [reservation].[ReservationMode] RM on v.ReservationModeID = RM.ReservationModeID
	inner join [account].[TransactionMode] TM on v.Hold_TransactionModeID = TM.TransactionModeID

	inner join [guest].[Guest] GT on v.GuestID = GT.GuestID
	inner join [contact].[Details] CD on GT.ContactID = CD.ContactID
	inner join [contact].[Address] AD on  CD.ContactID = AD.ContactID
	inner join [general].[Country] CN on AD.CountryID = CN.CountryID
	inner join [person].[Title] TL on CD.TitleID = TL.TitleID
			--LEFT JOIN reservation.vwKeyDepositAndKeyRefund kd ON v.ReservationID = kd.ReservationID
			--INNER JOIN reservation.ReservedRoom rr ON v.ReservationID = rr.ReservationID
			--INNER JOIN room.Room r ON rr.RoomID = r.RoomID
			--INNER JOIN room.RoomType rt ON r.RoomTypeID = rt.RoomTypeID	AND rr.IsActive = 1
	WHERE v.ReservationID = @ReservationID 
	AND v.LocationID = @LocationID
	AND v.ReservationStatusID = 1

	--EXEC [reservation].[spGetBookedRoomRate] @ReservationID
	select NightDate,Rooms, LineTotal from [reservation].[ReservationDetails]	where ReservationID = @ReservationID
	--SELECT CAST(fn.TotalAmount as decimal(18,2)) [TotalAmount]
	--,CAST(fn.DiscountAmount as decimal(18,2))[DiscountAmount]
	--,fn.Nights [Stay] 
	--FROM [reservation].[fnGetReservationRoomBill](6027) fn

	    SELECT COALESCE(ggc.CompanyID, 1) AS CompanyID, COALESCE(ggc.CompanyName, 'Guest') AS CompanyName
		FROM [reservation].[Reservation] rr
		LEFT JOIN guest.GuestCompany ggc ON ggc.CompanyID = rr.CompanyTypeID
		WHERE rr.ReservationID = @ReservationID;

		----START-------------------------------ADDED BY MURUGESH S 11-15-2023--------------------------------------------------------------------
		DECLARE @ReservedRoomsExist VARCHAR(255);
		EXEC @ReservedRoomsExist = [reservation].[fnGetReserveredRoom] @ReservationId;

		IF @ReservedRoomsExist IS NOT NULL AND @ReservedRoomsExist <> ''
		BEGIN
			-- Room numbers exist, load this query
			SELECT DISTINCT IT.ItemID, SC.Name, RM.RoomID, RM.RoomNo, Fl.[Floor], RM.Remarks, RM.RoomStatusID
			FROM [reservation].[ReservedRoom] RRR
			INNER JOIN [reservation].[ReservationDetails] RA ON RRR.ReservationID = RA.ReservationID
			INNER JOIN [Products].[Item] IT ON RA.ItemID = IT.ItemID
			INNER JOIN [Products].[Room] RM ON RRR.RoomID = RM.RoomID AND RM.IsActive = 1
			INNER JOIN [Products].[Floor] FL ON RM.FloorID = FL.FloorID
			INNER JOIN [Products].SubCategory SC ON IT.SubCategoryID = SC.SubCategoryID
			WHERE RRR.ReservationID = @ReservationId;
		END
		ELSE
		BEGIN
			-- Room numbers do not exist, load this query
			SELECT DISTINCT IT.ItemID, SC.Name, RM.RoomID, RM.RoomNo, Fl.[Floor], RM.Remarks
			FROM [reservation].[Reservation] RS
			INNER JOIN [reservation].[ReservationDetails] RD ON RS.ReservationID = RD.ReservationID
			INNER JOIN [Products].[Item] IT ON RD.ItemID = IT.ItemID
			INNER JOIN [Products].[Room] RM ON IT.SubCategoryID = RM.SubCategoryID AND RM.IsActive = 1 AND RM.RoomStatusID IN (1)
			INNER JOIN [Products].[Floor] FL ON RM.FloorID = FL.FloorID
			INNER JOIN [Products].SubCategory SC ON IT.SubCategoryID = SC.SubCategoryID
			WHERE RS.LocationID = @LocationID 
			AND IT.ItemID IN (SELECT DISTINCT ItemID FROM [reservation].[ReservationDetails] WHERE ReservationID = @ReservationID)
			ORDER BY SC.Name;
		END
		------END-----------------------------ADDED BY MURUGESH S 11-15-2023--------------------------------------------------------------------

	--select distinct IT.ItemID, IT.SubCategoryID, IT.ItemName,RM.RoomID,RM.RoomNo,Fl.[Floor], RM.Remarks 
	--from [reservation].[Reservation] RS
	--inner join [reservation].[ReservationDetails] RD on RS.ReservationID = RD.ReservationID
	--inner join [Products].[Item] IT on RD.ItemID = IT.ItemID
	--inner join [Products].[Room] RM on IT.SubCategoryID = RM.SubCategoryID and RM.IsActive = 1 and RM.RoomStatusID = 1--Vacant
	--inner join [Products].[Floor] FL on RM.FloorID= FL.FloorID
	--where RS.LocationID = @LocationID 
	--and IT.ItemID in(select distinct ItemID from [reservation].[ReservationDetails] where ReservationID = @ReservationID  ) --6227


			--and RS.ReservationID= @ReservationID Not required 
	--and (@ExpectedCheckInDate NOT BETWEEN ExpectedCheckIn AND ExpectedCheckOut OR @ExpectedCheckOutDate NOT BETWEEN ExpectedCheckIn AND ExpectedCheckOut)

	--select Distinct IT.ItemID, IT.ItemName,RD.Rooms 
	--from [reservation].[Reservation] RS
	--inner join [reservation].[ReservationDetails] RD on RS.ReservationID = RD.ReservationID
	--inner join [Products].[Item] IT on RD.ItemID = IT.ItemID
	--where RS.ReservationID= @ReservationID and RS.LocationID = @LocationID
		select Distinct IT.ItemID, IT.ItemName,RD.Rooms ,SC.Name as RoomType
	from [reservation].[Reservation] RS
	inner join [reservation].[ReservationDetails] RD on RS.ReservationID = RD.ReservationID
	inner join [Products].[Item] IT on RD.ItemID = IT.ItemID
	inner join Products.SubCategory SC on IT.SubCategoryID = SC.SubCategoryID
	where RS.ReservationID= @ReservationID and RS.LocationID = @LocationID

	select EM.[EmployeeID], CD.[FirstName] + ' '+ CD.[LastName] as [Name] from [general].[Employee] EM
	inner join [contact].[Details] CD on EM.ContactID = CD.ContactID
	inner join [general].[Designation] DS on CD.DesignationID = DS.DesignationID
	where  DS.[DesignationID] = 15 -- Bell Boy

	--[contact].[Details]
	--general.EmployeeAndLocation 
	
	
END
