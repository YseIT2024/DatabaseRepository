
CREATE Proc [room].[spAddCustomRoomRate]
(
	@LocationID int,
	@RoomTypeID int,
	@RateCode varchar(20),
	@RateTypeID int,	
	@Price decimal(18,2),
	@CurrencyID int,	
	@UserID int	
)
AS
BEGIN
	-- SET XACT_ABORT ON will cause the transaction to be uncommittable  
	-- when the constraint violation occurs.   
	SET XACT_ABORT ON;  
		
	DECLARE @PriceID int;
	DECLARE @RateID INT;
	DECLARE @RoomType VARCHAR(10);
	
	BEGIN TRY  
		BEGIN TRANSACTION
			IF EXISTS(SELECT PriceID FROM currency.Price WHERE Rate = @Price AND CurrencyID = @CurrencyID)
				BEGIN
					SET @PriceID = (SELECT PriceID FROM currency.Price WHERE Rate = @Price AND CurrencyID = @CurrencyID)
				END
			ELSE
				BEGIN
					INSERT INTO [currency].[Price]
					([Rate],[CurrencyID])
					VALUES(@Price,@CurrencyID)

					SET @PriceID = SCOPE_IDENTITY();
				END	
			
			INSERT INTO [room].[Rate]
			([RateCode],[LocationID],[RoomTypeID],[DurationID],[Adult1PriceID],[Adult2PriceID],[Adult3PriceID],[Adult4PriceID],[ExtraAdultPriceID],
			[ExtraChildPriceID],[IsSpecialRate],[ActivationDate],[UserID])
			VALUES(@RateCode, @LocationID, @RoomTypeID, @RateTypeID, @PriceID, 0, 0, 0, 0, 0, 0, GETDATE(), @UserID)
			
			SET @RateID	= SCOPE_IDENTITY();	
		COMMIT TRANSACTION
	END TRY  
	BEGIN CATCH    
		IF (XACT_STATE() = -1) 
		BEGIN  			
			ROLLBACK TRANSACTION;  			
		END;    
    
		IF (XACT_STATE() = 1)  
		BEGIN  			
			COMMIT TRANSACTION; 
		END;  

		-------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog] 3,@LocationID,@Act,@UserID	
	END CATCH;

	SELECT [RateID]
	,rat.RateCode 
	,c.CurrencySymbol
	,ISNULL([FromDateID],0) [FromDateID]
	,ISNULL([ToDateID],0) [ToDateID]
	,rat.[RoomTypeID]
	,ISNULL(pA1.Rate,0) [Adult1Price]
	,ISNULL(pA1.Rate,0) [Adult2Price]
	,ISNULL(pA1.Rate,0) [Adult3Price]
	,ISNULL(pA1.Rate,0) [Adult4Price]
	,0 [ExtraAdultPrice]
	,0 [ExtraChildPrice]
	,rat.IsSpecialRate
	,rat.IsActive
	,pA1.CurrencyID
	FROM [room].[Rate] rat	
	INNER JOIN currency.Price pA1 ON rat.Adult1PriceID = pA1.PriceID
	INNER JOIN currency.Currency c ON pA1.CurrencyID = c.CurrencyID
	WHERE rat.RateID = @RateID
END


