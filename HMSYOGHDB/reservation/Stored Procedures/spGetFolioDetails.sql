CREATE PROCEDURE [reservation].[spGetFolioDetails] --1,1,3,0
(	
	@ReservationID int,
	@LocationID int,
	@DrawerID int,
	@UserId int
)
AS
BEGIN
	SET NOCOUNT ON;	

	DECLARE @ActualCheckIn datetime;
	DECLARE @ActualCheckOut datetime;
	DECLARE @ActualStay int;
	DECLARE @RateCurrencyID INT;
	DECLARE @FolioNo INT=(select FolioNumber from reservation.Reservation where ReservationID=@ReservationID)

	--DECLARE @TotalServiceRate decimal;
	
	SELECT @ActualCheckIn = ActualCheckIn, @RateCurrencyID = CurrencyID, @ActualCheckOut= isnull (ActualCheckOut,GETDATE()) FROM reservation.Reservation
	WHERE ReservationID = @ReservationID AND LocationID = @LocationID --AND ReservationStatusID = 3


	--SET @ActualStay = (SELECT DATEDIFF(DAY, @ActualCheckIn, GETDATE()));
	SET @ActualStay = (SELECT DATEDIFF(DAY, @ActualCheckIn, @ActualCheckOut));

	IF(@ActualStay = 0)
	BEGIN
		SET @ActualStay = 1;
	END

	--select @TotalServiceRate = sum(ServiceRate) from [reservation].[ReservationServices] where ReservationID = 6058 and [Status] = 'A'
	
	SELECT Top 1 RS.[ReservationID]	,RS.[FolioNumber]	,RS.[GuestID] 	,RS.[ReservationStatusID]
			,FORMAT([ActualCheckIn],'dd-MMM-yyyy hh:mm tt') AS [ActualCheckIn]	,FORMAT([ActualCheckOut],'dd-MMM-yyyy hh:mm tt') AS [ActualCheckOut]	,
			FORMAT([ExpectedCheckIn],'dd-MMM-yyyy hh:mm tt') AS [ExpectedCheckIn],FORMAT([ExpectedCheckOut],'dd-MMM-yyyy hh:mm tt') AS [ExpectedCheckOut]	
			,TL.[Title] + ' ' + CD.[FirstName] + (CASE When LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END) AS [Name]
			,RS.[Adults]  	,RS.[Children]	,RD.[ExtraAdults] 	,RD.[ExtraChildren]
			,RS.[Rooms]	,RS.[Nights] 	,RT.[ReservationTypeID]	,RT.[ReservationType]
			,RM.[ReservationMode]		,AD.[PhoneNumber]
			,(CASE When LEN(AD.[Street]) > 0 THEN Ad.[Street] +', ' ELSE '' END) + (CASE When LEN(AD.[City]) > 0 THEN AD.[City] +', ' ELSE '' END)
			+ (CASE When LEN(AD.[State]) > 0 THEN AD.[State] +', ' ELSE '' END) + CN.[CountryName] + (CASE When LEN(AD.[ZipCode]) > 0 THEN ', '+ AD.[ZipCode]  ELSE '' END) as [Address]
			,FORMAT([DateTime],'dd-MMM-yyyy') AS [DateTime]	,RS.[AdditionalDiscount] as [Discount] 	,TM.[TransactionMode] as [Hold]		,AD.[Email]	
			,RS.AdditionalDiscountAmount	,RS.TotalPayable,
			CASE WHEN RS.CompanyID =1 THEN 'Guest' ELSE (Select CompanyName from [guest].[GuestCompany] where CompanyID=RS.CompanyTypeID) END AS [BillTo]
			--gc.CompanyName [BillTo] 
			,@RateCurrencyID RateCurrencyID	,RS.CompanyID	,fn.PayableAmount	,fn.TotalPayment	,fn.Balance	,LC.CheckOutTime
			--FROM [reservation].[vwReservationDetails] v	
			,(select [reservation].[fnGetReserveredRoom](RS.ReservationID)) as RoomNos
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

			--inner join general.Company gc on gc.CompanyID=RS.CompanyID

			inner join [general].[Location] LC on RS.LocationID = LC.LocationID
			CROSS APPLY (SELECT * FROM [account].[fnGetReservationPayments_New](RS.ReservationID)) fn
	WHERE RS.ReservationID = @ReservationID AND RS.LocationID = @LocationID --AND ReservationStatusID = 3 --AND rr.IsActive = 1
	
	--EXEC [reservation].[spGetBookedRoomRate] @ReservationID     Products.SubCategory
	
	--SELECT DISTINCT c.CompanyID, CompanyName
	--FROM company.Company c
	--INNER JOIN company.CompanyAndContactPerson ccp ON c.CompanyID = ccp.CompanyID or c.CompanyID = 0
	--WHERE ccp.IsActive = 1 
	--ORDER BY CompanyID

	--SELECT CompanyID, CompanyName FROM [general].[Company]		

	--select NightDate,Rooms, LineTotal from [reservation].[ReservationDetails]	where ReservationID = @ReservationID 

	--SELECT	FORMAT(RD.NightDate,'dd-MMM-yyyy')  as TransDate,
	--		RD.ItemID as ItemId,
	--		(PS.Name + '-' + IT.ItemName) as ItemDescription,
	--		RD.Rooms as Quantity,
	--		--RD.UnitPriceAfterTax AS Rate, 
	--		--RD.LineTotal as Amount,
	--		(RD.UnitPriceAfterTax-RD.TotalTaxAmount) AS Rate, 
	--		RD.UnitPriceAfterTax AS Amount,
	--		RD.TotalTax as TaxPercentage,
	--		RD.TotalTaxAmount as TaxAmount,
	--		--RD.TaxDetailID as TaxId
	--		(select top (1) taxid from reservation.ReservationTaxDetails where ReservationID=RS.ReservationID) as TaxId,
	--		--(select  ServiceTypeID from  service.Type where  LOWER(ServiceName)='room charges') as BillingCode
	--		(select  ServiceTypeID from  service.Type where ServiceTypeID=18) as BillingCode
	--		--(select 
	--FROM [reservation].[Reservation] RS
	--		inner join [reservation].[ReservationDetails] RD on RS.ReservationID = RD.ReservationID
	--		inner join [Products].[Item] IT on RD.ItemID = IT.ItemID
	--		INNER JOIN Products.SubCategory PS on IT.SubCategoryID=PS.SubCategoryID

	--WHERE RS.ReservationID=@ReservationID --and RS.LocationID = @LocationID
	--UNION ALL

	
	SELECT FORMAT(gld.TransDate,'dd-MMM-yyyy') AS TransDate, 
			gld.ServiceId as ItemId,
			st.ServiceName as ItemDescription,
			1 as Quantity,
			--gld.AmtAfterTax as Rate,
			gld.AmtBeforeTax as Rate,
			gld.AmtAfterTax as Amount,
			gld.TaxPer as TaxPercentage,
			isnull(gld.AmtTax,(gld.AmtAfterTax/(1+gld.TaxPer))) as TaxAmount,
			--(gld.AmtAfterTax/(1+gld.TaxPer)) as TaxAmount,
			--((gld.TaxPer/100) * gld.AmtAfterTax) as TaxAmount, ----Commented By Arabinda on 26/07/2023
			--gld.AmtTax as TaxAmount,----Added By Arabinda on 26/07/2023
			gld.TaxId as taxId,
			gld.ServiceId as BillingCode,
			ISNULL(gld.IsComplimentary,0)as IsComplimentary,
			ISNULL (gld.ComplimentaryPercentage,0) as ComplimentaryPercentage,
			gld.LedgerId
			FROM [account].[GuestLedgerDetails] gld
			Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
			WHERE gld.FolioNo=@FolioNo --and gld.ServiceId not in (18)

		 
	


	------To get the Transaction details

	SELECT TransactionID	,AccountType
	,CASE WHEN TransactionFactor = 1 THEN Amount ELSE 0 END [REC]
	,CASE WHEN TransactionFactor = -1 THEN ABS(Amount) ELSE 0 END [PAY]
	,Remarks	,TransactionMode	,EnteredBy
	,CASE WHEN vwt.ReservationID IS NULL THEN '' ELSE CAST(vwt.ReservationID as varchar(15)) END [ReservationID]
	,cd.FirstName + CASE WHEN cd.LastName IS NULL THEN '' ELSE ' '+ cd.LastName END [Person]
	,FORMAT(ad.AccountingDate,'dd-MMM-yyyy') [AccountingDate]
	,vwt.ActualCurrencyCode
	,ABS(vwt.ActualAmount) [ActualAmount]
	,vwt.ExchangeRate
	,TransactionType	
	,vwt.TransactionTypeID
	,TransactionFactor
	,CAST(0 as bit) IsVoid	
	,vwt.AccountTypeID	
	FROM [account].[vwTransaction] vwt		
	INNER JOIN account.AccountingDates ad ON vwt.AccountingDateID = ad.AccountingDateId		
	INNER JOIN contact.Details cd ON vwt.ContactID = cd.ContactID	
	--WHERE vwt.DrawerID = @DrawerID AND vwt.AccountingDateID = @AccountingDateID
	where vwt.ReservationID= @ReservationID
	ORDER BY TransactionID DESC
	

	--13371

	--select RS.TransId, SI.[Name] as ServiceName, RS.ServiceQty, RS.ServiceRate  from [reservation].[ReservationServices] RS
	--		Inner join [service].[Item] SI on RS.ServiceId = SI.ItemID
	--where RS.ReservationID = @ReservationID and RS.[Status] = 'A'

	--select EM.[EmployeeID], CD.[FirstName] + ' '+ CD.[LastName] as [Name] from [general].[Employee] EM
	--		inner join [contact].[Details] CD on EM.ContactID = CD.ContactID
	--		inner join [general].[Designation] DS on CD.DesignationID = DS.DesignationID
	--where  DS.[DesignationID] = 15 -- Bell Boy

	--SELECT * FROM reservation.ReservationDetails ORDER BY ReservationID

	--SELECT PayableAmount,TotalPayment,Balance  FROM [account].[fnGetReservationPayments](@ReservationID)
	
END
