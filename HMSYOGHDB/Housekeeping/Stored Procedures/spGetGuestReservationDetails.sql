CREATE PROCEDURE [Housekeeping].[spGetGuestReservationDetails]
(	
	@LocationID int,
	@FilterID int,
	@DrawerID int,
	@FromDate date,
	@Todate date
)
AS
BEGIN
	
	DECLARE @temp_ReservationIDs TABLE (ID INT);

	IF(@FilterID = 1) --InHouse
	BEGIN
		INSERT INTO @temp_ReservationIDs
		SELECT r.ReservationID
		FROM reservation.Reservation r
		WHERE r.[LocationID] = @LocationID 
		AND r.ReservationStatusID = 3 --InHouse			
	END
	ELSE IF(@FilterID = 2) --CheckedOut
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
	ELSE
	BEGIN
		INSERT INTO @temp_ReservationIDs
		SELECT r.ReservationID
		FROM reservation.Reservation r
		WHERE r.[LocationID] = @LocationID 
		AND r.ReservationStatusID NOT IN (3,4)
		AND
		(
			CAST(r.ExpectedCheckIn AS DATE) BETWEEN @FromDate AND @Todate
			OR CAST(r.ExpectedCheckOut AS DATE) BETWEEN @FromDate AND @Todate
			OR CAST(r.ActualCheckIn AS DATE) BETWEEN @FromDate AND @Todate
			OR CAST(r.ActualCheckOut AS DATE) BETWEEN @FromDate AND @Todate
			OR CAST(r.[DateTime] AS DATE) BETWEEN @FromDate AND @Todate
		)
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
	,FORMAT([DateTime],'dd-MMM-yyyy') as [DateTime]			
	,[Title] +' '+ [FirstName] + (CASE When LEN([LastName]) > 0 THEN ' '+ [LastName] ELSE '' END) as [Name]
	,[ReservationStatus]	
	,(CASE When LEN([Street]) > 0 THEN [Street] +', ' ELSE '' END) + (CASE When LEN([City]) > 0 THEN [City] +', ' ELSE '' END) 
	+ (CASE When LEN([State]) > 0 THEN [State] +', ' ELSE '' END)  + [CountryName] as [Address]
	,isnull([Email],'')[Email]
	,CA.[PhoneNumber]		
	,Comp.CompanyName BillTo
	,RR.Rooms	
	,(select isnull(sum(ActualAmount),0) from [account].[Transaction] where ReservationID = RR.ReservationID and LocationID = RR.LocationID) as [Advance]	
	,TotalPayable 	
	,(select (RR.TotalPayable - isnull(sum(ActualAmount),0)) from [account].[Transaction] where ReservationID = RR.ReservationID and LocationID = RR.LocationID) as Balance
	,Comp.CompanyID
	,RT.ReservationType
	,RM.ReservationMode
	,RR.ReservationTypeID
	,isnull(RR.RequiredAMT,0) RequiredAMT
	,RR.CurrencyID
	,RR.OnlineReservationID
	from reservation.Reservation RR
	inner join reservation.ReservationDetails RD on RR.ReservationID=RD.ReservationID
	inner join @temp_ReservationIDs TR on TR.ID=RR.ReservationID and RR.LocationID=@LocationID
	inner join guest.Guest GG on GG.GuestID=RR.GuestID
	inner join contact.Details CD on CD.ContactID=GG.ContactID
	inner join person.Title PT on PT.TitleID=CD.TitleID
	inner join contact.Address CA on CA.ContactID=CD.ContactID
	inner join general.Country GC on GC.CountryID=CA.CountryID
	inner join reservation.ReservationStatus RS on RS.ReservationStatusID=RR.ReservationStatusID
	inner join general.Company Comp on Comp.CompanyID=RR.CompanyID
	inner join reservation.ReservationType RT on RR.ReservationTypeID=RT.ReservationTypeID
	inner join reservation.ReservationMode RM on RR.ReservationModeID = RM.ReservationModeID	
	ORDER BY ReservationID,FolioNumber,GuestID,ReservationStatusID,ExpectedNight,ExpectedCheckIn,ExpectedCheckOut,ActualNight,ActualCheckIn,ActualCheckOut,[DateTime],
	[Name],[ReservationStatus],[Address],[Email],[PhoneNumber],BillTo,[Balance],CompanyID,ReservationType,[ReservationTypeID] DESC


END
