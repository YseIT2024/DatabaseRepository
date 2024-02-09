

CREATE PROCEDURE [reservation].[spGetCheckedOutReservation] --1,0,1,'2021-08-15','2023-08-28'
(	
	@LocationID int,
	@FilterID int,
	@DrawerID int,
	@FromDate date,
	@Todate date
)
AS
BEGIN
--Declare @LocationID int=1,
--	@FilterID int=0,
--	@DrawerID int=1,
--	@FromDate date='2022-Dec-03',
--	@Todate date='2022-Dec-13'
	/*
	FilterID = Default = 0
	FilterID = Today = 1
	FilterID = UpcomingCheckIn = 2
	FilterID = UpcomingCheckOut = 3
	FilterID = InHouse = 4
	FilterID = DepositsOnly = 5
	FilterID = GroupsOnly = 6
	FilterID = CheckedOut = 7
	FilterID = Canceled = 8
	FilterID = Last30Day = 9
	*/

	 DECLARE @temp_ReservationIDs TABLE (ID INT);

	IF(@FilterID = 0) --Default
		BEGIN
			INSERT INTO @temp_ReservationIDs
			SELECT r.ReservationID
			FROM reservation.Reservation r
			WHERE r.[LocationID] = @LocationID		
			AND
			(
				CAST(r.ExpectedCheckIn AS DATE) BETWEEN @FromDate AND @Todate
				OR CAST(r.ExpectedCheckOut AS DATE) BETWEEN @FromDate AND @Todate
				OR CAST(r.ActualCheckIn AS DATE) BETWEEN @FromDate AND @Todate
				OR CAST(r.ActualCheckOut AS DATE) BETWEEN CAST(GETDATE() AS DATE) AND CAST(GETDATE() AS DATE)
				OR CAST(r.[DateTime] AS DATE) BETWEEN @FromDate AND @Todate				
			)
			--select * from @temp_ReservationIDs
		END
	ELSE IF(@FilterID = 1) --Today
		BEGIN
			INSERT INTO @temp_ReservationIDs
			SELECT r.ReservationID
			FROM reservation.Reservation r
			WHERE r.[LocationID] = @LocationID
			AND
			(
				CAST(r.ExpectedCheckIn AS DATE) = CAST(GETDATE() AS DATE)
				OR CAST(r.ExpectedCheckOut AS DATE) = CAST(GETDATE() AS DATE)
				OR CAST(r.ActualCheckIn AS DATE) = CAST(GETDATE() AS DATE)
				OR CAST(r.ActualCheckOut AS DATE) = CAST(GETDATE() AS DATE)
				OR CAST(r.[DateTime] AS DATE) = CAST(GETDATE() AS DATE)
			)
		END
	ELSE IF(@FilterID = 2) --UpcomingCheckIn
		BEGIN
			INSERT INTO @temp_ReservationIDs
			SELECT r.ReservationID
			FROM reservation.Reservation r
			WHERE r.[LocationID] = @LocationID 
			AND r.ReservationStatusID = 1	
			AND
			(
				CAST(r.ExpectedCheckIn AS DATE) BETWEEN @FromDate AND @Todate
				OR CAST(r.ExpectedCheckOut AS DATE) BETWEEN @FromDate AND @Todate
				OR CAST(r.ActualCheckIn AS DATE) BETWEEN @FromDate AND @Todate
				OR CAST(r.ActualCheckOut AS DATE) BETWEEN @FromDate AND @Todate
				OR CAST(r.[DateTime] AS DATE) BETWEEN @FromDate AND @Todate
			)
		END
	ELSE IF(@FilterID = 3) --UpcomingCheckOut
		BEGIN
			INSERT INTO @temp_ReservationIDs
			SELECT r.ReservationID
			FROM reservation.Reservation r
			WHERE r.[LocationID] = @LocationID 
			AND r.ReservationStatusID = 3
			AND
			(
				@FromDate BETWEEN CAST(r.ExpectedCheckIn AS DATE) AND CAST(r.ExpectedCheckOut AS DATE)
				OR @Todate BETWEEN CAST(r.ExpectedCheckIn AS DATE) AND CAST(r.ExpectedCheckOut AS DATE)
				OR @FromDate BETWEEN CAST(r.ActualCheckIn AS DATE) AND CAST(r.ExpectedCheckOut AS DATE)
				OR @Todate BETWEEN CAST(r.ActualCheckIn AS DATE) AND CAST(r.ExpectedCheckOut AS DATE)				
				OR CAST(r.[DateTime] AS DATE) BETWEEN @FromDate AND @Todate
			)
		END
	ELSE IF(@FilterID = 4) --InHouse
		BEGIN
			INSERT INTO @temp_ReservationIDs
			SELECT r.ReservationID
			FROM reservation.Reservation r
			WHERE r.[LocationID] = @LocationID 
			AND r.ReservationStatusID = 3 --InHouse			
		END
	ELSE IF(@FilterID = 5) --DepositsOnly
		BEGIN
			INSERT INTO @temp_ReservationIDs
			SELECT r.ReservationID
			FROM reservation.Reservation r
			INNER JOIN
			(
				SELECT [ReservationID]   
				FROM [reservation].[vwKeyDepositAndKeyRefund]				
			) kd ON r.ReservationID = kd.ReservationID
			WHERE r.[LocationID] = @LocationID 
			AND r.ReservationStatusID IN (1,3)
			AND
			(
				CAST(r.ExpectedCheckIn AS DATE) BETWEEN @FromDate AND @Todate
				OR CAST(r.ExpectedCheckOut AS DATE) BETWEEN @FromDate AND @Todate
				OR CAST(r.ActualCheckIn AS DATE) BETWEEN @FromDate AND @Todate
				OR CAST(r.ActualCheckOut AS DATE) BETWEEN @FromDate AND @Todate
				OR CAST(r.[DateTime] AS DATE) BETWEEN @FromDate AND @Todate
			)
		END	
	ELSE IF(@FilterID = 7) --CheckedOut
		BEGIN
			INSERT INTO @temp_ReservationIDs
			SELECT r.ReservationID
			FROM reservation.Reservation r
			WHERE r.[LocationID] = @LocationID 
			AND r.ReservationStatusID = 4 --CheckedOut
			AND
			(
				CAST(r.ExpectedCheckIn AS DATE) BETWEEN @FromDate AND @Todate
				OR CAST(r.ExpectedCheckOut AS DATE) BETWEEN @FromDate AND @Todate
				OR CAST(r.ActualCheckIn AS DATE) BETWEEN @FromDate AND @Todate
				OR CAST(r.ActualCheckOut AS DATE) BETWEEN @FromDate AND @Todate
				OR CAST(r.[DateTime] AS DATE) BETWEEN @FromDate AND @Todate
			)
		END
	ELSE IF(@FilterID = 8) --Canceled
		BEGIN
			INSERT INTO @temp_ReservationIDs
			SELECT r.ReservationID
			FROM reservation.Reservation r
			WHERE r.[LocationID] = @LocationID 
			AND r.ReservationStatusID = 2 --Canceled
			AND
			(
				CAST(r.ExpectedCheckIn AS DATE) BETWEEN @FromDate AND @Todate
				OR CAST(r.ExpectedCheckOut AS DATE) BETWEEN @FromDate AND @Todate
				OR CAST(r.ActualCheckIn AS DATE) BETWEEN @FromDate AND @Todate
				OR CAST(r.ActualCheckOut AS DATE) BETWEEN @FromDate AND @Todate
				OR CAST(r.[DateTime] AS DATE) BETWEEN @FromDate AND @Todate
			)
		END
	ELSE IF(@FilterID = 9) --Last30Day
		BEGIN
			INSERT INTO @temp_ReservationIDs
			SELECT r.ReservationID
			FROM reservation.Reservation r
			WHERE r.[LocationID] = @LocationID 
			AND (CAST(r.[DateTime] AS DATE) BETWEEN CAST(DATEADD(DAY, -29, GETDATE()) AS DATE) AND CAST(GETDATE() AS DATE))		
		END

	SELECT  distinct RR.[ReservationID]
	,CASE WHEN RR.FolioNumber > 0 THEN  LTRIM(STR(RR.FolioNumber)) ELSE 'N/A' END [FolioNumber]
	,RR.[GuestID]	
	,RR.[ReservationStatusID]
	,[Nights] [ExpectedNight]
	,FORMAT([ExpectedCheckIn],'dd-MMM-yyyy') [ExpectedCheckIn]		
	,FORMAT([ExpectedCheckOut],'dd-MMM-yyyy') [ExpectedCheckOut]
	,CASE WHEN RR.ReservationStatusID = 3 THEN 
		(
			CASE WHEN (DATEDIFF(DAY, [ActualCheckIn], [ExpectedCheckOut])) <= 0 THEN 1 ELSE (DATEDIFF(DAY, [ActualCheckIn], [ExpectedCheckOut])) END
		)
		WHEN RR.ReservationStatusID = 4 THEN 
		(
			CASE WHEN DATEDIFF(DAY, [ActualCheckIn], [ActualCheckOut]) <= 0 THEN 1 ELSE (DATEDIFF(DAY, [ActualCheckIn], [ActualCheckOut])) END
		)
	ELSE [Nights] END [ActualNight]
	,CASE WHEN [ActualCheckIn] IS NOT NULL THEN FORMAT([ActualCheckIn],'dd-MMM-yyyy') ELSE 'n.a.' END [ActualCheckIn]
	,CASE WHEN [ActualCheckOut] IS NOT NULL THEN FORMAT([ActualCheckOut],'dd-MMM-yyyy') ELSE 'n.a.' END [ActualCheckOut]
	,RR.[Adults]
	,RR.[Children]
	--,RD.[Adults] + RD.[ExtraAdults] [Adults]
	--,RD.[Children] + RD.[ExtraChildren] [Children]	
	--,CAST(CASE WHEN kd.ReservationID IS NULL THEN 0.00 ELSE kd.KeyDeposit END as decimal(18,2)) [KeyDeposit]	
	,FORMAT([DateTime],'dd-MMM-yyyy') as [DateTime]			
	,[Title] +' '+ [FirstName] + (CASE When LEN([LastName]) > 0 THEN ' '+ [LastName] ELSE '' END) as [Name]
	,RS.[ReservationStatus]	
	,(CASE When LEN([Street]) > 0 THEN [Street] +', ' ELSE '' END) + (CASE When LEN([City]) > 0 THEN [City] +', ' ELSE '' END) 
	+ (CASE When LEN([State]) > 0 THEN [State] +', ' ELSE '' END)  + [CountryName] as [Address]
	,isnull([Email],'')[Email]
	,CA.[PhoneNumber]		
	--,Comp.CompanyName BillTo
	,CASE WHEN RR.CompanyID =1 THEN 'Guest' ELSE (Select CompanyName from [guest].[GuestCompany] where CompanyID=RR.CompanyTypeID) END AS BillTo 
	,RR.Rooms
	--,isnull(RateCurrencyID,0)RateCurrencyID
	--,isnull(sum(TRS.Amount),0) [Advance]
	,(select isnull(sum(ActualAmount),0) from [account].[Transaction] where ReservationID = RR.ReservationID and LocationID = RR.LocationID) as [Advance],
	--,isnull(payment.PayableAmount,0) [Payable]

	CASE WHEN rr.ReservationTypeID=10 then		
		TotalPayable-TotalPayable 
	ELSE
		--TotalPayable 
		isnull((select SUM(TotalAmountAfterTax) from reservation.Invoice where FolioNumber=RR.FolioNumber and ParentInvoiceNo is null),0)
	END AS TotalPayable ,	
	--,TotalPayable 
	--,(RR.TotalPayable - isnull(sum(TRS.Amount),0)) as [Balance]

	CASE WHEN rr.ReservationTypeID=10 then
		RR.TotalPayable - RR.TotalPayable
	ELSE		
		isnull((select ((select SUM(TotalAmountAfterTax) from reservation.Invoice where FolioNumber=RR.FolioNumber and ParentInvoiceNo is null) - isnull(sum(ActualAmount),0)) from [account].[Transaction] where ReservationID = RR.ReservationID and LocationID = RR.LocationID),0)
	END as Balance
	,RR.CompanyTypeID as CompanyID
	,RT.ReservationType
	,RM.ReservationMode
	,RR.ReservationTypeID,
	CASE WHEN rr.ReservationTypeID=10 then
		isnull((RR.RequiredAMT-RR.RequiredAMT) ,0)
	ELSE 
		isnull(RR.RequiredAMT,0) 
	END AS RequiredAMT

	,RR.CurrencyID
	,RR.OnlineReservationID
	,isnull(RRS.ReservationStatus, 'Express Checked Out') CheckOutType
	,isnull(RRS.ReservationStatusID, 13) as CheckOutTypeID	
	,isnull((SELECT top 1 [InvoiceNo] FROM [HMSYOGH].[reservation].[Invoice] WHERE [FolioNumber]=RR.FolioNumber and ParentInvoiceNo is null),0) AS InvoiceNo
	
	,isnull((SELECT top 1 
	
	case when InvoiceNumber is null then   CONVERT(nvarchar(50), InvoiceNo)
	else  InvoiceNumber  end InvoiceNumber
	
	FROM [reservation].[Invoice] WHERE [FolioNumber]=RR.FolioNumber and ParentInvoiceNo is null),0) AS InvoiceNumber

	,(select [reservation].[fnGetReserveredRoom](RR.ReservationID)) as RoomNos
	---------------New Column Added by MURUGESH S
	--,RR.TotalAmountAfterTax as TotalAmount
	--,RR.TotalTaxAmount as TotalTax
	,ISNULL((select SUM(TotalAmountAfterTax) from reservation.Invoice where FolioNumber=RR.FolioNumber and ParentInvoiceNo is null),0) as TotalAmount
	,ISNULL((select SUM(ServiceTaxAmount) from reservation.Invoice where FolioNumber=RR.FolioNumber and ParentInvoiceNo is null),0) as TotalTax
	,(select [reservation].[fnGetRoomCategory](RR.ReservationID))as RoomCategory
	,(select [reservation].[fnGetRoomMealPlan](RR.ReservationID))as MealPlan
	--,(select [reservation].[fnGetRoomType](RR.ReservationID))as RoomType
	-----------END---------------
 
  	---------------New Column Added by Vasanth
	,isnull((select case when ISNULL(g.GuestSignature,'') = '' then '0' else '1' end from reservation.Invoice i inner join  reservation.GuestSignature g on i.InvoiceNo=g.InvoiceNo where g.IsActive=1 and i.FolioNumber=RR.FolioNumber  and ISNULL(i.ParentInvoiceNo,'')=''),'0') as IsGuestSignature
	,isnull((select case when ISNULL(g.ManagerSignature,'') = '' then '0' else '1' end from reservation.Invoice i inner join  reservation.GuestSignature g on i.InvoiceNo=g.InvoiceNo where g.IsActive=1 and i.FolioNumber=RR.FolioNumber  and ISNULL(i.ParentInvoiceNo,'')=''),'0') as IsManagerSignature
	-----------END---------------
	
	from reservation.Reservation RR
	inner join reservation.ReservationDetails RD on RR.ReservationID=RD.ReservationID
	inner join @temp_ReservationIDs TR on TR.ID=RR.ReservationID and RR.LocationID=@LocationID
	inner join guest.Guest GG on GG.GuestID=RR.GuestID
	inner join contact.Details CD on CD.ContactID=GG.ContactID
	inner join person.Title PT on PT.TitleID=CD.TitleID
	inner join contact.Address CA on CA.ContactID=CD.ContactID
	inner join general.Country GC on GC.CountryID=CA.CountryID
	inner join reservation.ReservationStatus RS on RS.ReservationStatusID=RR.ReservationStatusID
	--inner join general.Company Comp on Comp.CompanyID=RR.CompanyID
	inner join reservation.ReservationType RT on RR.ReservationTypeID=RT.ReservationTypeID
	inner join reservation.ReservationMode RM on RR.ReservationModeID = RM.ReservationModeID

	Left join [reservation].[CheckOutDetail] RCD on RR.ReservationID = RCD.ReservationID
	Left join reservation.ReservationStatus RRS on RCD.ReservationStatusID = RRS.ReservationStatusID

	--Left join [account].[Transaction] TRS on RR.ReservationID = TRS.ReservationID
	--FROM [reservation].[vwReservationDetails] rd
	--INNER JOIN @temp_ReservationIDs t ON rd.ReservationID = t.ID AND rd.LocationID = @LocationID
	--INNER JOIN [reservation].[ReservationDetails] rDetails ON t.ID = rDetails.ReservationID
	----LEFT JOIN reservation.vwKeyDepositAndKeyRefund kd ON rd.ReservationID = kd.ReservationID
	----CROSS APPLY (SELECT * FROM [account].[fnGetReservationPayments](rd.ReservationID)) payment
	--group by RR.ReservationID, RR.FolioNumber, RR.GuestID, RR.ReservationStatusID,RR.Nights,RR.ExpectedCheckIn,RR.ExpectedCheckOut,
	--		RR.ActualCheckIn,RR.ActualCheckOut,RR.Adults,RR.Children,RR.DateTime
	ORDER BY  ReservationID DESC
	--ORDER BY ReservationID,FolioNumber,GuestID,RR.ReservationStatusID,ExpectedNight,ExpectedCheckIn,ExpectedCheckOut,ActualNight,ActualCheckIn,ActualCheckOut,[DateTime],[Name],RS.[ReservationStatus],[Address],[Email],[PhoneNumber],BillTo,[Balance],CompanyID,ReservationType,[ReservationTypeID] DESC
	---ORDER BY ExpectedCheckOut DESC
END
