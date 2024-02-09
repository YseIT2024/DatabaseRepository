
CREATE PROCEDURE [reservation].[spGetReservationToChangeRate]--10064,5
(
	@FolioNumber int,
	@LocationID int
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ReservationID int;

	SELECT @ReservationID = r.ReservationID
	FROM [reservation].[Reservation] r
	WHERE r.FolioNumber = @FolioNumber AND r.LocationID = @LocationID AND ReservationStatusID IN (1,3)

	SELECT r.ReservationID
	,([Title] + ' ' + (SELECT dbo.fnPascalCase(FirstName)) + ' ' + (SELECT dbo.fnPascalCase(LastName))) FullName
	,'(' + rat.RateCode + ') Avg Rate '+ c.CurrencySymbol + CAST(CAST(rrr.Rate as decimal(18,2)) as varchar(10)) Rate
	,rm.RoomNo
	,rrr.RateID
	FROM [reservation].[Reservation] r
	INNER JOIN reservation.ReservedRoom rr ON r.ReservationID = rr.ReservationID AND rr.IsActive = 1
	CROSS APPLY (SELECT TOP 1 RateID, Rate FROM reservation.RoomRate WHERE ReservedRoomID = rr.ReservedRoomID) rrr
	INNER JOIN room.Rate rat ON rrr.RateID = rat.RateID
	INNER JOIN currency.Price p ON rat.Adult1PriceID = p.PriceID
	INNER JOIN currency.Currency c ON p.CurrencyID = c.CurrencyID
	INNER JOIN room.Room rm ON rr.RoomID = rm.RoomID
	INNER JOIN [guest].[Guest] g ON r.GuestID = g.GuestID
	INNER JOIN [contact].[Details] cd ON g.ContactID = cd.ContactID
	INNER JOIN [person].[Title] t ON cd.TitleID = t.TitleID
	WHERE r.ReservationID = @ReservationID

	SELECT r.RateID
	,r.RateCode + ' (Curr -> ' + cA1.CurrencyCode + ')' [RateCode]
	,cA1.CurrencySymbol [Currency]
	,CASE WHEN r.Adult1PriceID IS NOT NULL THEN pA1.Rate ELSE 0 END [1Adult] 
	,CASE WHEN r.Adult2PriceID IS NOT NULL THEN pA2.Rate ELSE 0 END [2Adult]
	,CASE WHEN r.Adult3PriceID IS NOT NULL THEN pA3.Rate ELSE 0 END [3Adult]
	,CASE WHEN r.Adult4PriceID IS NOT NULL THEN pA4.Rate ELSE 0 END [4Adult]
	,CASE WHEN r.ExtraAdultPriceID IS NOT NULL THEN pEx.Rate ELSE 0 END [ExtraAdult]
	,CASE WHEN r.ExtraChildPriceID IS NOT NULL THEN pCh.Rate ELSE 0 END [ExtraChild]  
	,cA1.CurrencyID
	FROM room.Rate r
	INNER JOIN 
	(
		SELECT TOP 1 rm.RoomTypeID
		FROM [reservation].[Reservation] r
		INNER JOIN reservation.ReservedRoom rr ON r.ReservationID = rr.ReservationID AND rr.IsActive = 1
		INNER JOIN room.Room rm ON rr.RoomID = rm.RoomID		
		WHERE r.ReservationID = @ReservationID
	) details ON r.RoomTypeID = details.RoomTypeID
	INNER JOIN currency.Price pA1 ON r.Adult1PriceID = pA1.PriceID
	INNER JOIN currency.Currency cA1 ON pA1.CurrencyID = cA1.CurrencyID
	INNER JOIN currency.Price pA2 ON r.Adult2PriceID = pA2.PriceID	
	LEFT JOIN currency.Price pA3 ON r.Adult3PriceID = pA3.PriceID	
	LEFT JOIN currency.Price pA4 ON r.Adult4PriceID = pA4.PriceID	
	INNER JOIN currency.Price pEx ON r.ExtraAdultPriceID = pEx.PriceID	
	INNER JOIN currency.Price pCh ON r.ExtraChildPriceID = pCh.PriceID	
	WHERE r.IsActive = 1 AND r.LocationID = @LocationID	
	
	SELECT TOP 1 rr.RateCurrencyID, rs.ReservationStatus
	FROM [reservation].[Reservation] re
	INNER JOIN reservation.ReservedRoom rr ON re.ReservationID = rr.ReservationID AND rr.IsActive = 1	
	INNER JOIN reservation.ReservationStatus rs ON re.ReservationStatusID = rs.ReservationStatusID	
	WHERE re.ReservationID = @ReservationID
END

