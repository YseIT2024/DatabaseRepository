
CREATE PROCEDURE [company].[spGetCompanyReservationSummary] --1, '02-21-2020', '08-21-2020'
(
	@DrawerID int,
	@FromDate date,
	@ToDate date,
	@UserID int = null	
)
AS
BEGIN
	DECLARE @LocationID int = (Select LocationID From app.Drawer Where DrawerID = @DrawerID);	

	SELECT rd.CompanyID
	,c.CompanyName
	,rd.FolioNumber
	,FORMAT(rd.DateTime,'dd-MMM-yyyy') [ReservationDate]	
	,FORMAT(ISNULL([ActualCheckIn],[ExpectedCheckIn]),'dd-MMM-yyyy') [CheckIn]		
	,FORMAT(ISNULL([ActualCheckOut],[ExpectedCheckOut]),'dd-MMM-yyyy') [CheckOut]
	,CASE WHEN ReservationStatusID = 3 THEN 
		(
			CASE WHEN (DATEDIFF(DAY, [ActualCheckIn], [ExpectedCheckOut])) <= 0 THEN 1 ELSE (DATEDIFF(DAY, [ActualCheckIn], [ExpectedCheckOut])) END
		)
		WHEN ReservationStatusID = 4 THEN 
		(
			CASE WHEN DATEDIFF(DAY, [ActualCheckIn], [ActualCheckOut]) <= 0 THEN 1 ELSE (DATEDIFF(DAY, [ActualCheckIn], [ActualCheckOut])) END
		)
		ELSE [Nights] END [Nights]		
	,[Adults] + [ExtraAdults] [Adults]
	,[Children]				
	,[Title] +' '+ [FirstName] + (CASE When LEN([LastName]) > 0 THEN ' '+ [LastName] ELSE '' END) as [GuestName]
	,[ReservationStatus]	
	,(CASE When LEN([Street]) > 0 THEN [Street] +', ' ELSE '' END) + (CASE When LEN([City]) > 0 THEN [City] +', ' ELSE '' END) 
	+ (CASE When LEN([State]) > 0 THEN [State] +', ' ELSE '' END)  + [CountryName] as [Address]		
	FROM [reservation].[vwReservationDetails] rd	
	INNER JOIN company.Company c ON rd.CompanyID = c.CompanyID
	WHERE rd.CompanyID > 0 AND rd.LocationID = @LocationID AND CAST(rd.[DateTime] as date) BETWEEN @FromDate AND @ToDate

	-----Insert in Log Table -----------------
	EXEC [app].[spInsertActivityLog] 4, @LocationID , 'Company Reservation Summary', @UserID
END

