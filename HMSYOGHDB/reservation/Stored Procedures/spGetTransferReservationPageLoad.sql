

CREATE PROCEDURE [reservation].[spGetTransferReservationPageLoad] --6687, 1,1
(
	@ReservationID INT,
	@LocationID INT,
	@isInHouse BIT = 0
)
AS
BEGIN	
	DECLARE @RateCurrencyID int;
	DECLARE @Amount DECIMAL(18,2);	
	
	SET @Amount = 0;
	-------------------------------------------------

	SELECT DISTINCT r.FolioNumber
	,([Title] + ' ' + (SELECT dbo.fnPascalCase(FirstName)) + ' ' + (SELECT dbo.fnPascalCase(LastName))) AS [Name]

	,FORMAT(ISNULL(r.ActualCheckIn,r.ExpectedCheckIn),'dd-MMM-yyyy') [CheckIn] 
	,FORMAT(r.ExpectedCheckOut,'dd-MMM-yyyy') [CheckOut]
	,@Amount TotalAmount
	,r.CurrencyID as RateCurrencyID	
	,r.ReservationTypeID
	
	--r.[ExpectedCheckIn], r.[ExpectedCheckOut], r.[ActualCheckIn], r.[ActualCheckOut]
	--,r.[GuestID],  r.[Rooms], r.[Nights], r.[ReservationStatusID],  r.LocationID, r.[DateTime]	
	--,(SELECT dbo.fnPascalCase(FirstName)) [FirstName]
	--,(SELECT dbo.fnPascalCase(LastName)) [LastName]	
	--,cd.[ContactID], cd.[TitleID]
	--,t.Title, r.ReservationTypeID
	FROM [reservation].[Reservation] r	
	INNER JOIN [guest].[Guest] g ON r.GuestID = g.GuestID
	INNER JOIN [contact].[Details] cd ON g.ContactID = cd.ContactID
	INNER JOIN [person].[Title] t ON cd.TitleID = t.TitleID
	where r.ReservationID= @ReservationID
	
	
	--SELECT FolioNumber
	--,[Title] +' '+ [FirstName] + (CASE When LEN([LastName]) > 0 THEN ' '+ [LastName] ELSE '' END) as [Name]
	--,FORMAT(ISNULL(ActualCheckIn,ExpectedCheckIn),'dd-MMM-yyyy') [CheckIn] 
	--,FORMAT(ExpectedCheckOut,'dd-MMM-yyyy') [CheckOut]
	----,@Amount TotalAmount
	--,RateCurrencyID	
	--,ReservationTypeID
	--FROM [reservation].[vwReservationDetails] 	
	--WHERE ReservationID = @ReservationID AND LocationID = @LocationID

	--408

	    Select Psc.SubCategoryID,Psc.Name [RoomType],prm.RoomNo,prm.RoomID
		from reservation.ReservedRoom rrr
		INNER JOIN Products.Room prm ON rrr.RoomID=prm.RoomID
		INNER JOIN Products.SubCategory  Psc  ON prm.SubCategoryID=psc.SubCategoryID
		Where rrr.ReservationID=@ReservationID AND rrr.IsActive=1

		
END
--select * from [reservation].[vwReservationDetails] 