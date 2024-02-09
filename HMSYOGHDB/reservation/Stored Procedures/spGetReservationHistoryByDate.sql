

CREATE Proc [reservation].[spGetReservationHistoryByDate]
(	
	@FromDate date,
	@ToDate date,
	@LocationID int
)
AS
BEGIN
	SELECT 		
	r.[ReservationID]
	,(l.LocationCode + CAST(r.FolioNumber as varchar(20))) FolioNumber
	,[Title] +' '+ [FirstName] + (CASE When LEN([LastName]) > 0 THEN ' '+ [LastName] ELSE '' END) as [GuestName]
	,[CountryName] as [Address]
	,[Adults] + [ExtraAdults] [Adults]
	,[Children]
	,[Nights] [ExpectedNight]
	,FORMAT([ExpectedCheckIn],'dd-MMM-yyyy') [ExpectedCheckIn]
	,FORMAT([ExpectedCheckOut],'dd-MMM-yyyy') [ExpectedCheckOut]
	,CASE WHEN r.ReservationStatusID = 3 THEN 
		(
			CASE WHEN (DATEDIFF(DAY, [ActualCheckIn], [ExpectedCheckOut])) <= 0 THEN 1 ELSE (DATEDIFF(DAY, [ActualCheckIn], [ExpectedCheckOut])) END
		)
		WHEN r.ReservationStatusID = 4 THEN 
		(
			CASE WHEN DATEDIFF(DAY, [ActualCheckIn], [ActualCheckOut]) <= 0 THEN 1 ELSE (DATEDIFF(DAY, [ActualCheckIn], [ActualCheckOut])) END
		)
	ELSE [Nights] END [ActualNight]
	,CASE WHEN [ActualCheckIn] IS NOT NULL THEN FORMAT([ActualCheckIn],'dd-MMM-yyyy') ELSE 'n.a.' END [ActualCheckIn]
	,CASE WHEN [ActualCheckOut] IS NOT NULL THEN FORMAT([ActualCheckOut],'dd-MMM-yyyy') ELSE 'n.a.' END [ActualCheckOut]
	,FORMAT([DateTime],'dd-MMM-yyyy') as [DateTime]
	,rs.ReservationStatus
	,CASE WHEN r.CompanyID > 0 THEN com.CompanyName ELSE ([Title] + ' ' + (SELECT dbo.fnPascalCase(FirstName)) + ' ' + (SELECT dbo.fnPascalCase(LastName))) END [BillTo]
	FROM [reservation].[Reservation] r
	INNER JOIN reservation.ReservedRoom rr ON r.ReservationID = rr.ReservationID AND rr.IsActive = 1		
	INNER JOIN general.[Location] l ON r.LocationID = l.LocationID	
	INNER JOIN [reservation].[ReservationStatus] rs ON r.ReservationStatusID = rs.ReservationStatusID
	INNER JOIN [guest].[Guest] g ON r.GuestID = g.GuestID
	INNER JOIN [contact].[Details] cd ON g.ContactID = cd.ContactID
	INNER JOIN [person].[Title] t ON cd.TitleID = t.TitleID
	INNER JOIN [contact].[Address] a ON cd.ContactID = a.ContactID
	INNER JOIN [general].[Country] c ON a.CountryID = c.CountryID
	INNER JOIN [company].[Company] com on r.CompanyID = com.CompanyID
	WHERE r.LocationID = @LocationID AND CAST(r.[DateTime] as date) BETWEEN @FromDate AND @ToDate
END

