

CREATE VIEW [reservation].[vwReservationDetails]
AS
	SELECT DISTINCT r.[ReservationID], r.[ExpectedCheckIn], r.[ExpectedCheckOut], r.[ActualCheckIn], r.[ActualCheckOut]
	,r.[GuestID],  r.[Rooms], r.[Nights], r.[ReservationStatusID],  r.LocationID, r.[DateTime]
	,(l.LocationCode + CAST(r.FolioNumber as varchar(20))) FolioNumber
	,(SELECT dbo.fnPascalCase(FirstName)) [FirstName]
	,(SELECT dbo.fnPascalCase(LastName)) [LastName]
	,([Title] + ' ' + (SELECT dbo.fnPascalCase(FirstName)) + ' ' + (SELECT dbo.fnPascalCase(LastName))) AS [FullName]
	,rt.[ReservationType], rm.[ReservationMode], cd.[ContactID], cd.[TitleID]
	,t.Title, rs.[ReservationStatus], tm.[TransactionMode] AS [Hold]
	,ISNULL(a.[Street],'') AS [Street], ISNULL(a.[City],'') AS [City], ISNULL(a.[State],'') AS [State]
	,ISNULL(a.[ZipCode],'') AS [ZipCode], a.[CountryID], c.CountryName,ISNULL(a.[Email],'n/a') AS [Email], a.[PhoneNumber]
	--,CAST(ISNULL([AvgDiscount],0) as decimal(18,2)) AS [Discount]	
	,cur.CurrencyCode
	,CASE WHEN r.CompanyID =1 THEN 'Guest' ELSE (Select CompanyName from [guest].[GuestCompany] where CompanyID=r.CompanyTypeID) END AS [BillTo] 
	--,CASE WHEN r.CompanyID > 0 THEN com.CompanyName ELSE ([Title] + ' ' + (SELECT dbo.fnPascalCase(FirstName)) + ' ' + (SELECT dbo.fnPascalCase(LastName))) END [BillTo]
	,FORMAT(RoomChargeEffectDate,'dd-MMM-yyyy') [RoomChargeEffectDate]
	,r.CompanyID
	,rr.RateCurrencyID
	,r.ReservationTypeID
	FROM [reservation].[Reservation] r
	INNER JOIN reservation.ReservedRoom rr ON r.ReservationID = rr.ReservationID AND rr.IsActive = 1
	--INNER JOIN [reservation].[vwAverageDiscount] dis ON dis.ReservationID = r.ReservationID
	INNER JOIN currency.Currency cur ON rr.RateCurrencyID = cur.CurrencyID
	INNER JOIN general.[Location] l ON r.LocationID = l.LocationID 
	INNER JOIN [reservation].[ReservationType] rt ON r.ReservationTypeID = rt.ReservationTypeID
	INNER JOIN [reservation].[ReservationMode] rm ON r.ReservationModeID = rm.ReservationModeID
	INNER JOIN [reservation].[ReservationStatus] rs ON r.ReservationStatusID = rs.ReservationStatusID
	INNER JOIN [account].[TransactionMode] tm ON r.Hold_TransactionModeID = tm.TransactionModeID	
	left JOIN [guest].[Guest] g ON r.GuestID = g.GuestID
	left JOIN [contact].[Details] cd ON g.ContactID = cd.ContactID
	left JOIN [person].[Title] t ON cd.TitleID = t.TitleID
	left JOIN [contact].[Address] a ON cd.ContactID = a.ContactID
	left JOIN [general].[Country] c ON a.CountryID = c.CountryID

	--INNER JOIN [general].[Company] com on r.CompanyID = com.CompanyID


