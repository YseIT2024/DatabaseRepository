
CREATE PROCEDURE [reservation].[spGetReservationByLocation]  --1,0,1,'2023-12-01','2023-12-30'
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
	DECLARE @OTAReservationID int;
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
	,FORMAT([ExpectedCheckIn],'dd-MMM-yyyy HH:mm') [ExpectedCheckIn]	
	,FORMAT([ExpectedCheckOut],'dd-MMM-yyyy HH:mm') [ExpectedCheckOut]
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
	--,FORMAT([dbo].[GetDatetimeBasedonTimezone](DateTime),'dd-MMM-yyyy') as [DateTime]
	,[Title] +' '+ [FirstName] + (CASE When LEN([LastName]) > 0 THEN ' '+ [LastName] ELSE '' END) as [Name]
	,[ReservationStatus]	
	,(CASE When LEN([Street]) > 0 THEN [Street] +', ' ELSE '' END) + (CASE When LEN([City]) > 0 THEN [City] +', ' ELSE '' END) 
	+ (CASE When LEN([State]) > 0 THEN [State] +', ' ELSE '' END)  + [CountryName] as [Address]
	,isnull([Email],'')[Email]
	,CA.[PhoneNumber]		
	--,Comp.CompanyName BillTo	
	-------------------------
	--,CASE WHEN RR.ReservationTypeID > 1 THEN 
	--		(SELECT CompanyName FROM [guest].[GuestCompany] where CompanyID=rr.CompanyTypeID) 	
	--	ELSE 'Guest'		
	--END		BillTo

	----------------------------------------------------
	---Added By Murugesh s--------
	,CASE WHEN RR.CompanyID =1 THEN 'Guest' ELSE (Select CompanyName from [guest].[GuestCompany] where CompanyID=RR.CompanyTypeID) END AS BillTo 
	---Added By Murugesh s--------
	,RR.Rooms
	--,isnull(RateCurrencyID,0)RateCurrencyID
	--,isnull(sum(TRS.Amount),0) [Advance]
	----------------------------------------
	--,(select isnull(sum(ActualAmount),0) from [account].[Transaction] where ReservationID = RR.ReservationID and LocationID = RR.LocationID and AccountTypeID = 23) as [Advance], --Vivek:- Here only Account type id 23(Advance Payment) is considered
	,(select isnull(sum(ActualAmount),0) from [account].[Transaction] where ReservationID = RR.ReservationID and LocationID = RR.LocationID ) as [Advance], 
	
	CASE WHEN rr.ReservationTypeID=10 then
	 0
	ELSE
	(SELECT isnull(CAST(RR.TotalPayable AS DECIMAL(18, 3)),0)+ ISNULL(sum(GLD.AmtAfterTax),0)  from [account].[GuestLedgerDetails] GLD where GLD.FolioNo=rr.FolioNumber and GC.IsActive=1 and ServiceId<>18)
	
	END AS TotalPayable,

	--CASE WHEN rr.ReservationTypeID=10 then
	--  (RR.TotalPayable - RR.TotalPayable )     
	--ELSE
	--	(select (RR.TotalPayable - isnull(sum(ActualAmount),0)) from [account].[Transaction] where ReservationID = RR.ReservationID and LocationID = RR.LocationID )   
	--END AS Balance
	CASE
        WHEN RR.ReservationTypeID = 10 THEN 0
        ELSE
            ISNULL(CAST(RR.TotalPayable AS DECIMAL(18, 3)), 0) +
            ISNULL((SELECT SUM(GLD.AmtAfterTax)
                    FROM [account].[GuestLedgerDetails] AS GLD
                    WHERE GLD.FolioNo = RR.FolioNumber
                      AND GLD.ServiceId <> 18), 0) -
            ISNULL((SELECT SUM(ActualAmount)
                    FROM [account].[Transaction]
                    WHERE ReservationID = RR.ReservationID AND LocationID = RR.LocationID), 0)
    END AS Balance
	
	--,Comp.CompanyID
	,ISNULL(rr.CompanyTypeID,0) as CompanyId  -- ISNULL VALIDATE BY VASANTH
	,RT.ReservationType
	,RM.ReservationMode,
	----Commented by Arabinda on 17-11-2023 to show BookedBy for all mode 
	--CASE WHEN RR.ReservationModeID = 1 THEN
 --       (SELECT TL.[Title] + ' ' + CD.[FirstName] + (CASE WHEN LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END)
 --        FROM reservation.Reservation RI
 --        INNER JOIN app.[User] au ON RI.UserID = au.UserID
 --        INNER JOIN [contact].[Details] CD ON au.ContactID = CD.ContactID
 --        INNER JOIN [person].[Title] TL ON CD.TitleID = TL.TitleID
 --        WHERE RI.ReservationID = RR.ReservationID)
 --   ELSE 'N/A' -- Change 'N/A' to the desired default value when ReservationMode is not 1
 --   END AS BookedBy

		(SELECT TL.[Title] + ' ' + CD.[FirstName] + (CASE WHEN LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END)
         FROM reservation.Reservation RI
         INNER JOIN app.[User] au ON RI.UserID = au.UserID
         INNER JOIN [contact].[Details] CD ON au.ContactID = CD.ContactID
         INNER JOIN [person].[Title] TL ON CD.TitleID = TL.TitleID
         WHERE RI.ReservationID = RR.ReservationID) AS BookedBy,
------------------------------ADDED TO GET THE LAST UPDATED BY------

CASE WHEN RR.ReservationStatusID = 4 THEN
        (SELECT TOP 1 TL.[Title] + ' ' + CD.[FirstName] + (CASE WHEN LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END)
         FROM Reservation.CheckOutDetail RI
         INNER JOIN app.[User] au ON RI.CreatedBy = au.UserID
         INNER JOIN [contact].[Details] CD ON au.ContactID = CD.ContactID
         INNER JOIN [person].[Title] TL ON CD.TitleID = TL.TitleID
         WHERE RI.ReservationID = RR.ReservationID)
		  WHEN RR.ReservationStatusID = 2 THEN
		 (SELECT TOP 1 TL.[Title] + ' ' + CD.[FirstName] + (CASE WHEN LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END)
         FROM reservation.CancellationDetail RI
         INNER JOIN app.[User] au ON RI.CreatedBy = au.UserID
         INNER JOIN [contact].[Details] CD ON au.ContactID = CD.ContactID
         INNER JOIN [person].[Title] TL ON CD.TitleID = TL.TitleID
         WHERE RI.ReservationID = RR.ReservationID)
		
		 WHEN RR.ReservationStatusID = 12 THEN
		 (SELECT TOP 1 TL.[Title] + ' ' + CD.[FirstName] + (CASE WHEN LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END)
         FROM reservation.Reservation RI
         INNER JOIN app.[User] au ON RI.UserID = au.UserID
         INNER JOIN [contact].[Details] CD ON au.ContactID = CD.ContactID
         INNER JOIN [person].[Title] TL ON CD.TitleID = TL.TitleID
         WHERE RI.ReservationID = RR.ReservationID)
		  WHEN RR.ReservationStatusID = 1 THEN
		 (SELECT TOP 1 TL.[Title] + ' ' + CD.[FirstName] + (CASE WHEN LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END)
         FROM reservation.ReservationStatusLog RI
         INNER JOIN app.[User] au ON RI.UserID = au.UserID
         INNER JOIN [contact].[Details] CD ON au.ContactID = CD.ContactID
         INNER JOIN [person].[Title] TL ON CD.TitleID = TL.TitleID
         WHERE RI.ReservationID = RR.ReservationID AND RI.Remarks='Reserved')
		 WHEN RR.ReservationStatusID = 3 THEN
		 (SELECT TOP 1 TL.[Title] + ' ' + CD.[FirstName] + (CASE WHEN LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END)
         FROM reservation.ReservationStatusLog RI
         INNER JOIN app.[User] au ON RI.UserID = au.UserID
         INNER JOIN [contact].[Details] CD ON au.ContactID = CD.ContactID
         INNER JOIN [person].[Title] TL ON CD.TitleID = TL.TitleID
         WHERE RI.ReservationID = RR.ReservationID AND RI.ReservationStatusID=3)        
		 ELSE 'N/A' -- Change 'N/A' to the desired default value when ReservationMode is not 1
    END AS LastUpdatedBy
	----------------------------------------------
	
	,RR.ReservationTypeID
	--,isnull(RR.RequiredAMT,0) RequiredAMT
	,isnull(CAST(RR.RequiredAMT AS DECIMAL(18, 3)),0) RequiredAMT --Vivek - Rounding off to 3 decimals
	,RR.CurrencyID
	,RR.OnlineReservationID	
	,(select [reservation].[fnGetReserveredRoom](RR.ReservationID)) as RoomNos
	--,(select
	
	------------New Column Added by vasanth
	,(select [reservation].[fnGetRoomCategory](RR.ReservationID))as RoomCategory
	,(select [reservation].[fnGetRoomMealPlan](RR.ReservationID))as MealPlan
	,(select [reservation].[fnGetRoomType](RR.ReservationID))as RoomType
	,RR.TotalAmountAfterTax as TotalAmount
	,RR.TotalTaxAmount as TotalTax
	--,RR.DateTime As  CreatedOn
	,[dbo].[GetDatetimeBasedonTimezone] (RR.DateTime) As  CreatedOn

	,isnull((SELECT top 1 [InvoiceNo] FROM [HMSYOGH].[reservation].[Invoice] WHERE [FolioNumber]=RR.FolioNumber),0) AS InvoiceNo   ---LINE ADDED BY MURUGESH S 
	,ISNULL(RR.AuthorizedFlag,0) AS AuthorizedFlag,
	case 
	when RR.AuthorizedFlag=0 then 'Approved'
	when RR.AuthorizedFlag=1 then 'Pending for (' + (select [reservation].[fnGetResrvationApprovalPending] (RR.ReservationID))+')'
	when RR.AuthorizedFlag=2 then 'Rejected'
	else '' end as ApprovalStatus,

	isnull((select top(1) Reason from reservation.CancellationDetail  where ReservationID=RR.ReservationID),'') as CancellationReason,

	isnull((select top(1) PaymentMode  from [reservation].[OnlinePaymentResponse]  where ReferenceId=RR.ReservationID),'') as OnlineReservation,
	RR.Hold_TransactionModeID,TM.TransactionMode
	,ISNULL(@OTAReservationID,0) as OTAReservationID  --Added By Murugesh s
	,ISNULL(rst.SalesTypeID,0)as SalesTypeID,ISNULL(rst.SalesType,' ')as SalesType
	--,case when EXISTS(select ReservationID from [guest].[OTAServices] where ReservationID=RR.ReservationID) then 1 else 0 end as IsSplitInvoice
	,case when (select count(distinct GuestID_CompanyID)  from [guest].[OTAServices] where ReservationID=RR.ReservationID) > 1 then 1 else 0 end as IsSplitInvoice
	,case when RR.ReservationTypeID=1 then (select COUNT(*) from reservation.ReservationGuestMates rgm where rgm.ReservationID=RR.ReservationID)
	 else 2 END IsValidSplitInvoice
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
	inner join [account].[TransactionMode] TM on rr.Hold_TransactionModeID=TM.TransactionModeID
	Left join [reservation].[SalesTypes] rst on rr.SalesTypeID=rst.SalesTypeID
	--Left join [account].[Transaction] TRS on RR.ReservationID = TRS.ReservationID
	--FROM [reservation].[vwReservationDetails] rd
	--INNER JOIN @temp_ReservationIDs t ON rd.ReservationID = t.ID AND rd.LocationID = @LocationID
	--INNER JOIN [reservation].[ReservationDetails] rDetails ON t.ID = rDetails.ReservationID
	----LEFT JOIN reservation.vwKeyDepositAndKeyRefund kd ON rd.ReservationID = kd.ReservationID
	----CROSS APPLY (SELECT * FROM [account].[fnGetReservationPayments](rd.ReservationID)) payment
	--group by RR.ReservationID, RR.FolioNumber, RR.GuestID, RR.ReservationStatusID,RR.Nights,RR.ExpectedCheckIn,RR.ExpectedCheckOut,
	--		RR.ActualCheckIn,RR.ActualCheckOut,RR.Adults,RR.Children,RR.DateTime
	-----COMMENTED BY MURUGESH S
	--ORDER BY ReservationID,FolioNumber,GuestID,ReservationStatusID,ExpectedNight,ExpectedCheckIn,ExpectedCheckOut,ActualNight,ActualCheckIn,ActualCheckOut,[DateTime],[Name],[ReservationStatus],[Address],[Email],[PhoneNumber],BillTo,[Balance],CompanyID,ReservationType,[ReservationTypeID] DESC
	--WHERE RR.ReservationStatusID<>17
	--------NEW LINE ADDED BY MURUGESH S
	--ORDER BY CreatedOn DESC  --Commented By Rajendra
	ORDER BY RR.ReservationID DESC  -- Added By Rajendra

	---------END-----------
END

