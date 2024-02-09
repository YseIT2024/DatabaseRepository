
CREATE Proc [reservation].[spGetInHouseRoomChangeRateDetails]-- 6, 2609, 1, 67, '2021-09-30'
(
	@RoomTypeID INT,
	@ReservationID INT,	
	@LocationID INT,	
	@RateID INT,
	@MoveDate DATETIME
)
AS
BEGIN
	DECLARE @NoOfDays INT
	DECLARE @DATE DATE = CONVERT(DATE,@MoveDate);
	DECLARE @DateID INT;
	DECLARE @Adults INT;
	DECLARE @ExtraAdults INT;
	DECLARE @Chlid INT;
	DECLARE @StandardFreeChild int = (SELECT [Value] FROM app.Parameter WHERE ParameterID = 1);
	DECLARE @Count INT = 0;	
	DECLARE @Temp1 TABLE ([Date] VARCHAR(11), DateID INT, Rate DECIMAL(18,2), RateID INT); 
	DECLARE @Temp2 TABLE (DateID INT, Rate DECIMAL(18,2)); 
	DECLARE @ReservationTypeID int;
	DECLARE @InHouseRateID DECIMAL(18,2);
	DECLARE @InHouseRoomTypeID INT;
	DECLARE @ExpectedCheckOut DATE

	SELECT @ExpectedCheckOut = CONVERT(DATE, ExpectedCheckOut)
	 ,@Adults = Adults
	,@ExtraAdults = ExtraAdults
	,@Chlid = (CASE WHEN Children > @StandardFreeChild THEN (Children - @StandardFreeChild) ELSE 0 END)
	,@ReservationTypeID = ReservationTypeID
	FROM [reservation].[Reservation] WHERE ReservationID = @ReservationID	
	
	SELECT @InHouseRateID = MAX(RateID)	
	,@InHouseRoomTypeID = RoomTypeID
	FROM reservation.[Reservation] r
	INNER JOIN reservation.[ReservedRoom] rr ON r.ReservationID = rr.ReservationID 
	INNER JOIN reservation.[RoomRate] rt ON rr.ReservedRoomID = rt.ReservedRoomID 
	INNER JOIN room.Room rm ON rr.RoomID = rm.RoomID
	WHERE r.ReservationID = @ReservationID AND r.LocationID = @LocationID AND rr.IsActive = 1 AND rt.IsActive = 1 AND rt.IsVoid = 0
	GROUP BY RateCurrencyID, RoomTypeID

	SET @NoOfDays = (SELECT DATEDIFF(DAY, @Date, @ExpectedCheckOut)) 

	WHILE(@Count < @NoOfDays)
	BEGIN	
		INSERT INTO @Temp1([Date],DateID,Rate,RateID)
		SELECT FORMAT(@DATE,'dd-MMM-yyyy')
		,FORMAT(@DATE, 'yyyyMMdd')
		,CASE WHEN @Adults = 1 THEN CAST(ISNULL(pA1.Rate,0) + (@ExtraAdults * ISNULL(pEA.Rate,0)) + (@Chlid * ISNULL(pEC.Rate,0)) as decimal(18,2))
					WHEN @Adults = 2 THEN CAST(CASE WHEN ISNULL(pA2.Rate,0) = 0 THEN  ISNULL(pA1.Rate,0) ELSE  ISNULL(pA2.Rate,0) END 
									+ (@ExtraAdults * ISNULL(pEA.Rate,0)) + (@Chlid * ISNULL(pEC.Rate,0)) as decimal(18,2))
					WHEN @Adults = 3 THEN CAST(CASE WHEN ISNULL(pA3.Rate,0) = 0 THEN  ISNULL(pA1.Rate,0) ELSE ISNULL(pA3.Rate,0) END
									+ (@ExtraAdults * ISNULL(pEA.Rate,0)) + (@Chlid * ISNULL(pEC.Rate,0)) as decimal(18,2))
					WHEN @Adults = 4 THEN CAST(CASE WHEN ISNULL(pA4.Rate,0) = 0 THEN ISNULL(pA1.Rate,0) ELSE  ISNULL(pA4.Rate,0) END  
									+ (@ExtraAdults * ISNULL(pEA.Rate,0)) + (@Chlid * ISNULL(pEC.Rate,0)) as decimal(18,2)) END [Rate]
		,rat.RateID
		FROM [room].[Rate] rat
		INNER JOIN currency.Price pA1 ON rat.Adult1PriceID = pA1.PriceID
		LEFT JOIN currency.Price pA2 ON rat.Adult2PriceID = pA2.PriceID
		LEFT JOIN currency.Price pEA ON rat.ExtraAdultPriceID = pEA.PriceID
		LEFT JOIN currency.Price pEC ON rat.ExtraChildPriceID = pEC.PriceID
		LEFT JOIN currency.Price pA3 ON rat.Adult3PriceID = pA3.PriceID
		LEFT JOIN currency.Price pA4 ON rat.Adult4PriceID = pA4.PriceID	
		WHERE RateID = @RateID 

		--SELECT * FROM @Temp1

		INSERT INTO @Temp2(DateID,Rate)
		SELECT
		FORMAT(@DATE, 'yyyyMMdd')
		,CASE WHEN @Adults = 1 THEN CAST(ISNULL(pA1.Rate,0) + (@ExtraAdults * ISNULL(pEA.Rate,0)) + (@Chlid * ISNULL(pEC.Rate,0)) as decimal(18,2))
					WHEN @Adults = 2 THEN CAST(CASE WHEN ISNULL(pA2.Rate,0) = 0 THEN  ISNULL(pA1.Rate,0) ELSE  ISNULL(pA2.Rate,0) END 
									+ (@ExtraAdults * ISNULL(pEA.Rate,0)) + (@Chlid * ISNULL(pEC.Rate,0)) as decimal(18,2))
					WHEN @Adults = 3 THEN CAST(CASE WHEN ISNULL(pA3.Rate,0) = 0 THEN  ISNULL(pA1.Rate,0) ELSE ISNULL(pA3.Rate,0) END
									+ (@ExtraAdults * ISNULL(pEA.Rate,0)) + (@Chlid * ISNULL(pEC.Rate,0)) as decimal(18,2))
					WHEN @Adults = 4 THEN CAST(CASE WHEN ISNULL(pA4.Rate,0) = 0 THEN ISNULL(pA1.Rate,0) ELSE  ISNULL(pA4.Rate,0) END  
									+ (@ExtraAdults * ISNULL(pEA.Rate,0)) + (@Chlid * ISNULL(pEC.Rate,0)) as decimal(18,2)) END [Rate]	
		FROM [room].[Rate] rat
		INNER JOIN currency.Price pA1 ON rat.Adult1PriceID = pA1.PriceID
		LEFT JOIN currency.Price pA2 ON rat.Adult2PriceID = pA2.PriceID
		LEFT JOIN currency.Price pEA ON rat.ExtraAdultPriceID = pEA.PriceID
		LEFT JOIN currency.Price pEC ON rat.ExtraChildPriceID = pEC.PriceID
		LEFT JOIN currency.Price pA3 ON rat.Adult3PriceID = pA3.PriceID
		LEFT JOIN currency.Price pA4 ON rat.Adult4PriceID = pA4.PriceID	
		WHERE RateID = @InHouseRateID 

		SET @Count = @Count + 1;
		SET @DATE = DATEADD(DAY,1,@DATE);

		--SELECT * FROM @Temp2
	END

	SELECT [Date], t1.DateID, t1.Rate, RateID, t2.Rate AS [InHouseRate] FROM @Temp1 t1
	INNER JOIN @Temp2 t2 ON T1.DateID = t2.DateID
END

