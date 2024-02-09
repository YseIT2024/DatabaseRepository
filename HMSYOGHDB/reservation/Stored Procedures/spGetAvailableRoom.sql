
CREATE Proc [reservation].[spGetAvailableRoom]
(
	@LocationID int,
	@CheckInDateId int,
	@CheckOutDateId int,
	@ReservationID int = 0,
	@RateID int = 0,
	@ReservationTypeID int,
	@dtRoomTypeID as [app].[dtID] readonly
)
AS
BEGIN
	SET NOCOUNT ON;	
	
	DECLARE @temp_Cur TABLE (CurrencyID int);

	IF(@ReservationTypeID = 3) --Casino Reservation
		BEGIN
			INSERT INTO @temp_Cur
			(CurrencyID)
			SELECT [CasinoRateCurrencyID] FROM general.[Location] WHERE LocationID = @LocationID;
		END
	ELSE
		BEGIN
			INSERT INTO @temp_Cur 
			(CurrencyID)
			SELECT CurrencyID FROM currency.Currency;
		END

	SELECT r.RoomID, r.RoomNo, r.RoomTypeID, rt.RoomType
	FROM room.Room r
	INNER JOIN room.RoomType rt ON r.RoomTypeID = rt.RoomTypeID		
	LEFT JOIN [room].[fnGetUnavailableRoom] (@CheckInDateId, @CheckOutDateId, @dtRoomTypeID, @ReservationID) AS navail ON r.RoomID = navail.RoomID
	WHERE r.LocationID = @LocationID AND r.RoomTypeID IN (SELECT ID FROM @dtRoomTypeID)	AND r.IsActive = 1 AND navail.RoomID IS NULL		
	ORDER BY r.RoomNo, rt.RoomType

	SELECT [RateID]
	,rat.RateCode 
	,c.CurrencySymbol
	,ISNULL([FromDateID],0) [FromDateID]
	,ISNULL([ToDateID],0) [ToDateID]
	,rat.[RoomTypeID]
	,dua.[Duration] [RateType]
	,ISNULL(pA1.Rate,0) [Adult1Price]
	,ISNULL(pA2.Rate,0) [Adult2Price]
	,ISNULL(pA3.Rate,0) [Adult3Price]
	,ISNULL(pA4.Rate,0) [Adult4Price]
	,ISNULL(pEA.Rate,0) [ExtraAdultPrice]
	,ISNULL(pEC.Rate,0) [ExtraChildPrice]
	,rat.IsSpecialRate
	,rat.IsActive
	,pA1.CurrencyID
	FROM [room].[Rate] rat	
	INNER JOIN reservation.Duration dua  ON rat.DurationID = dua.DurationID
	INNER JOIN currency.Price pA1 ON rat.Adult1PriceID = pA1.PriceID
	INNER JOIN currency.Currency c ON pA1.CurrencyID = c.CurrencyID
	INNER JOIN currency.Price pA2 ON rat.Adult2PriceID = pA2.PriceID
	INNER JOIN currency.Price pEA ON rat.ExtraAdultPriceID = pEA.PriceID
	INNER JOIN currency.Price pEC ON rat.ExtraChildPriceID = pEC.PriceID
	LEFT JOIN currency.Price pA3 ON rat.Adult3PriceID = pA3.PriceID
	LEFT JOIN currency.Price pA4 ON rat.Adult4PriceID = pA4.PriceID	
	WHERE rat.LocationID = @LocationID AND (rat.IsActive = 1 OR rat.RateID = @RateID) AND rat.IsSpecialRate = 0
	AND c.CurrencyID IN (SELECT CurrencyID FROM @temp_Cur)
	AND rat.RoomTypeID IN (SELECT ID FROM @dtRoomTypeID) AND rat.RoomTypeID IS NOT NULL
	
	UNION

	SELECT [RateID]
	,rat.RateCode 
	,c.CurrencySymbol
	,ISNULL([FromDateID],0) [FromDateID]
	,ISNULL([ToDateID],0) [ToDateID]   
	,rat.[RoomTypeID]
	,dua.[Duration] [RateType]
	,ISNULL(pA1.Rate,0) [Adult1Price]
	,ISNULL(pA2.Rate,0) [Adult2Price]
	,ISNULL(pA3.Rate,0) [Adult3Price]
	,ISNULL(pA4.Rate,0) [Adult4Price]
	,ISNULL(pEA.Rate,0) [ExtraAdultPrice]
	,ISNULL(pEC.Rate,0) [ExtraChildPrice]
	,rat.IsSpecialRate
	,rat.IsActive
	,pA1.CurrencyID
	FROM [room].[Rate] rat
	INNER JOIN reservation.Duration dua  ON rat.DurationID = dua.DurationID
	INNER JOIN currency.Price pA1 ON rat.Adult1PriceID = pA1.PriceID
	INNER JOIN currency.Currency c ON pA1.CurrencyID = c.CurrencyID
	INNER JOIN currency.Price pA2 ON rat.Adult2PriceID = pA2.PriceID
	INNER JOIN currency.Price pEA ON rat.ExtraAdultPriceID = pEA.PriceID
	INNER JOIN currency.Price pEC ON rat.ExtraChildPriceID = pEC.PriceID
	LEFT JOIN currency.Price pA3 ON rat.Adult3PriceID = pA3.PriceID
	LEFT JOIN currency.Price pA4 ON rat.Adult4PriceID = pA4.PriceID	
	WHERE rat.LocationID = @LocationID AND (rat.IsActive = 1 OR rat.RateID = @RateID) AND rat.IsSpecialRate = 1
	AND c.CurrencyID IN (SELECT CurrencyID FROM @temp_Cur)
	AND rat.RoomTypeID IN (SELECT ID FROM @dtRoomTypeID) AND rat.RoomTypeID IS NOT NULL
	AND
	(
		@CheckInDateId BETWEEN rat.FromDateID AND rat.ToDateID OR @CheckOutDateId BETWEEN rat.FromDateID AND rat.ToDateID
		OR rat.FromDateID BETWEEN @CheckInDateId AND @CheckOutDateId OR rat.ToDateID BETWEEN @CheckInDateId AND @CheckOutDateId
	)
END


