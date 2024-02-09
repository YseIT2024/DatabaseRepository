

CREATE PROCEDURE [reservation].[spGetTransferReservationPageLoads] --850, 1,0
(
	@ReservationID INT,
	@LocationID INT,
	@isInHouse BIT = 0
)
AS
BEGIN	
	DECLARE @RateCurrencyID int;
	DECLARE @Amount DECIMAL(18,2);	
Declare 
	@SubCategoryID int=(Select Top 1 I.SubCategoryID FROM [reservation].[ReservationDetails] rd Join Products.Item I On I.ItemID=rd.ItemID where rd.ReservationID= @ReservationID),
	@ExpectedCheckInDate datetime=(Select ISNULL(r.ActualCheckIn, r.ExpectedCheckIn) FROM [reservation].[Reservation] r where r.ReservationID= @ReservationID),
	@ExpectedCheckOutDate datetime=(Select ISNULL(r.ActualCheckOut, r.ExpectedCheckOut) FROM [reservation].[Reservation] r where r.ReservationID= @ReservationID);
	
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

	 --   Select Psc.SubCategoryID,Psc.Name [RoomType],prm.RoomNo,prm.RoomID
		--from reservation.ReservedRoom rrr
		--INNER JOIN Products.Room prm ON rrr.RoomID=prm.RoomID
		--INNER JOIN Products.SubCategory  Psc  ON prm.SubCategoryID=psc.SubCategoryID
		--Where rrr.ReservationID=@ReservationID AND rrr.IsActive=1

		Select distinct Psc.SubCategoryID,Psc.Name [RoomType],prm.RoomNo,prm.RoomID, I.ItemID, I.ItemName--, rd.UnitPriceAfterDiscount BaseRate
		from reservation.ReservedRoom rrr
		INNER JOIN Products.Room prm ON rrr.RoomID=prm.RoomID
		INNER JOIN Products.SubCategory  Psc  ON prm.SubCategoryID=psc.SubCategoryID
		Join (Select Top 1 * From reservation.reservationdetails Where ReservationID = @ReservationID Order By NightDate DESC  ) As rd 
		--Join reservation.reservationdetails rd 
		ON rd.ReservationID=rrr.ReservationID 
		JOin Products.item I ON I.ItemID=rd.ItemID
		Where rrr.ReservationID=@ReservationID AND rrr.IsActive=1


		Exec [reservation].[MoveInHOuseGetProductDetail] @SubCategoryID, @ExpectedCheckInDate, @ExpectedCheckOutDate,0,0,0,0,@ReservationID

		Select distinct rd.ItemID, rd.NightDate , rd.UnitPriceAfterDiscount BaseRate 
		from reservation.reservationdetails rd 
		Where rd.ReservationID=@ReservationID 
		
END
--select * from [reservation].[vwReservationDetails] 