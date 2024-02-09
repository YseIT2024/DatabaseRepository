
CREATE PROCEDURE [reservation].[spReservationPageLoad]--1,1
(	
	@LocationID int,
	@DrawerID int
)
AS
BEGIN
	select 0 as RoomTypeID,'SELECT' as RoomType
	union all
	SELECT DISTINCT rt.SubCategoryID RoomTypeID, Name  RoomType
	FROM Products.SubCategory rt
	INNER JOIN Products.Room r ON rt.SubCategoryID = r.SubCategoryID
	WHERE r.LocationID = @LocationID AND r.IsActive = 1 and rt.IsActive=1 AND rt.CategoryID=1

	SELECT TitleID, Title
	FROM person.Title	

	SELECT ReservationTypeID, ReservationType
	FROM reservation.ReservationType where IsActive =1
	
	SELECT CountryID, CountryName  
	FROM general.Country
	WHERE IsActive = 1
	ORDER BY CountryName

	SELECT TransactionModeID, TransactionMode
	FROM [account].TransactionMode

	SELECT ReservationModeID, ReservationMode
	FROM reservation.ReservationMode where ReservationModeID <> 4 -- Online (not required fror offline reservation)
		
	SELECT CompanyID, CompanyName
	FROM general.Company
	--WHERE CompanyID = 0
	--UNION
	--SELECT DISTINCT c.CompanyID, CompanyName
	--FROM general.Company c
	--INNER JOIN company.CompanyAndContactPerson ccp ON c.CompanyID = ccp.CompanyID 
	--WHERE ccp.IsActive = 1 AND c.CompanyID > 0
	--ORDER BY CompanyID

	SELECT c.CurrencyID, CurrencyCode
	,er.NewRate CurrencyRateUSD
	,c.IsStrongerThanMainCurrency
	FROM [currency].[Currency] c 
	INNER JOIN [currency].[ExchangeRateHistory] er ON c.CurrencyID = er.CurrencyID 
	WHERE er.IsActive = 1 AND er.DrawerID = @DrawerID

	SELECT CurrencyID, CurrencyCode	
	FROM [currency].[Currency] 

	SELECT SalesTypeID,SalesType
	FROM [reservation].[SalesTypes]

	--SELECT StandardCheckInTime,StandardCheckOutTime FROM [reservation].[StandardCheckInOutTime]
	SELECT CONVERT(varchar(30), CONVERT(time, StandardCheckInTime), 100) AS StandardCheckInTime,
	CONVERT(varchar(30), CONVERT(time, StandardCheckOutTime), 100) AS StandardCheckOutTime
   FROM [reservation].[StandardCheckInOutTime]
END


