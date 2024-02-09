
CREATE Proc [reservation].[spGetBookingDateRateDetails] --3,2363,4,1,0,261
(
	@RoomTypeID INT,
	@ReservationID INT,
	@NoOfDays INT,	
	@LocationID INT,
	@IsExtend bit = 0,
	@RateID INT
)
AS
BEGIN
	DECLARE @DATE DATE;
	DECLARE @DateID INT;
	DECLARE @Adults INT;
	DECLARE @ExtraAdults INT;
	DECLARE @Chlid INT;
	DECLARE @StandardFreeChild int = (SELECT [Value] FROM app.Parameter WHERE ParameterID = 1);
	DECLARE @Count INT = 0;	
	DECLARE @Temp TABLE ([Date] VARCHAR(11) , DateID INT, Rate DECIMAL(18,2), RateID INT);
	DECLARE @ReservationTypeID int;

	SELECT @DATE = CASE WHEN @IsExtend = 1 THEN CONVERT(DATE,ExpectedCheckOut) ELSE CONVERT(DATE,ExpectedCheckIn) END
	,@Adults = Adults
	,@ExtraAdults = ExtraAdults
	,@Chlid = (CASE WHEN Children > @StandardFreeChild THEN (Children - @StandardFreeChild) ELSE 0 END)
	,@ReservationTypeID = ReservationTypeID
	FROM [reservation].[Reservation] WHERE ReservationID = @ReservationID				

	WHILE(@Count < @NoOfDays)
	BEGIN	
		IF(@ReservationTypeID = 7) ---For house use
			BEGIN
				INSERT INTO @Temp([Date], DateID, Rate, RateID)
				SELECT FORMAT(@DATE,'dd-MMM-yyyy'), FORMAT(@DATE, 'yyyyMMdd'), 0, 230
			END
		ELSE
			BEGIN 
				INSERT INTO @Temp([Date],DateID,Rate,RateID)
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
			END

		SET @Count = @Count + 1;
		SET @DATE = DATEADD(DAY,1,@DATE);
	END

	SELECT [Date], DateID, Rate, RateID FROM @Temp
END

