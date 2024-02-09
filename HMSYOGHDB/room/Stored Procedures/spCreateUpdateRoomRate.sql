CREATE Proc [room].[spCreateUpdateRoomRate]
(
	@RateID int,
	@LocationID int,
	@RoomTypeID int,
	@RateCode varchar(20) = null,
	@RateTypeID int,
	@FromDate datetime = null,
	@Todate datetime = null,
	@PriceA1 decimal(18,2),
	@CurrencyID int,
	@PriceA2 decimal(18,2),	
	@PriceA3 decimal(18,2),	
	@PriceA4 decimal(18,2),	
	@PriceExtra decimal(18,2),	
	@PriceChild decimal(18,2),	
	@IsSpecialRate bit,
	@UserID int	
)
AS
BEGIN
	-- SET XACT_ABORT ON will cause the transaction to be uncommittable  
	-- when the constraint violation occurs.   
	SET XACT_ABORT ON;  
	
	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(250) = '';
	DECLARE @Adult1PriceID INT = null;
	DECLARE @Adult2PriceID INT = null;
	DECLARE @Adult3PriceID INT = null;
	DECLARE @Adult4PriceID INT = null;
	DECLARE @ExtraPriceID INT = null;
	DECLARE @ChildPriceID INT = null;	
	DECLARE @RoomType VARCHAR(10);
	
	BEGIN TRY  
		BEGIN TRANSACTION
			IF EXISTS(SELECT PriceID FROM currency.Price WHERE Rate = @PriceA1 AND CurrencyID = @CurrencyID)
				BEGIN
					SET @Adult1PriceID = (SELECT PriceID FROM currency.Price WHERE Rate = @PriceA1 AND CurrencyID = @CurrencyID)
				END
			ELSE
				BEGIN
					INSERT INTO [currency].[Price]
					([Rate],[CurrencyID])
					VALUES(@PriceA1,@CurrencyID)

					SET @Adult1PriceID = SCOPE_IDENTITY();
				END	
			
			IF EXISTS(SELECT PriceID FROM currency.Price WHERE Rate = @PriceA2 AND CurrencyID = @CurrencyID)
				BEGIN
					SET @Adult2PriceID = (SELECT PriceID FROM currency.Price WHERE Rate = @PriceA2 AND CurrencyID = @CurrencyID)
				END
			ELSE
				BEGIN
					INSERT INTO [currency].[Price]
					([Rate],[CurrencyID])
					VALUES(@PriceA2,@CurrencyID)

					SET @Adult2PriceID = SCOPE_IDENTITY();
				END
					
			IF(@PriceA3 > 0)	
			BEGIN
				IF EXISTS(SELECT PriceID FROM currency.Price WHERE Rate = @PriceA3 AND CurrencyID = @CurrencyID)
					BEGIN
						SET @Adult3PriceID = (SELECT PriceID FROM currency.Price WHERE Rate = @PriceA3 AND CurrencyID = @CurrencyID)
					END
				ELSE
					BEGIN
						INSERT INTO [currency].[Price]
						([Rate],[CurrencyID])
						VALUES(@PriceA3,@CurrencyID)

						SET @Adult3PriceID = SCOPE_IDENTITY();
					END		
			END
					
			IF(@PriceA4 > 0)	
			BEGIN
				IF EXISTS(SELECT PriceID FROM currency.Price WHERE Rate = @PriceA4 AND CurrencyID = @CurrencyID)
					BEGIN
						SET @Adult4PriceID = (SELECT PriceID FROM currency.Price WHERE Rate = @PriceA4 AND CurrencyID = @CurrencyID)
					END
				ELSE
					BEGIN
						INSERT INTO [currency].[Price]
						([Rate],[CurrencyID])
						VALUES(@PriceA4,@CurrencyID)

						SET @Adult4PriceID = SCOPE_IDENTITY();
					END		
			END

			IF EXISTS(SELECT PriceID FROM currency.Price WHERE Rate = @PriceExtra AND CurrencyID = @CurrencyID)
				BEGIN
					SET @ExtraPriceID = (SELECT PriceID FROM currency.Price WHERE Rate = @PriceExtra AND CurrencyID = @CurrencyID)
				END
			ELSE
				BEGIN
					INSERT INTO [currency].[Price]
					([Rate],[CurrencyID])
					VALUES(@PriceExtra,@CurrencyID)

					SET @ExtraPriceID = SCOPE_IDENTITY();
				END

			IF EXISTS(SELECT PriceID FROM currency.Price WHERE Rate = @PriceChild AND CurrencyID = @CurrencyID)
				BEGIN
					SET @ChildPriceID = (SELECT PriceID FROM currency.Price WHERE Rate = @PriceChild AND CurrencyID = @CurrencyID)
				END
			ELSE
				BEGIN
					INSERT INTO [currency].[Price]
					([Rate],[CurrencyID])
					VALUES(@PriceChild,@CurrencyID)

					SET @ChildPriceID = SCOPE_IDENTITY();
				END

			IF @RateID <> 0
				BEGIN
					DECLARE @Desc varchar(250);
					DECLARE @UserName varchar(100) = (SELECT CONCAT(FirstName,' ',LastName) 
					FROM [contact].[Details] d
					INNER JOIN [app].[User] u ON d.ContactID = u.ContactID
					WHERE u.UserID = @UserID)

					DECLARE @Location varchar(100) = (SELECT LocationCode FROM [general].[Location] 
					WHERE LocationID = @LocationID) 

					SET @Desc = 
					(
						'Deactivate by user id:' + CAST(@UserID as varchar(10)) + '(' + @UserName + ')' + ' on ' 
						+ CAST(GETDATE() as varchar(50)) + ' (' + @Location + ')'
					);

					UPDATE room.Rate 
					SET IsActive = 0 
					,[Description] = @Desc
					WHERE RateID = @RateID

					DECLARE @NewRateID INT;
				END	

			IF NOT EXISTS (SELECT RateID FROM [room].[Rate] WHERE LocationID = @LocationID AND RoomTypeID = @RoomTypeID AND RateCode = @RateCode AND DurationID = @RateTypeID AND IsActive = 1 AND RateID <> @RateID)
				BEGIN				
			 		INSERT INTO [room].[Rate]
					([RateCode],[LocationID],[RoomTypeID],[DurationID],[Adult1PriceID],[Adult2PriceID],[Adult3PriceID],[Adult4PriceID],[ExtraAdultPriceID],[ExtraChildPriceID],
					[IsSpecialRate],[FromDateID],[ToDateID],[ActivationDate],[UserID])
					VALUES(@RateCode, @LocationID, @RoomTypeID, @RateTypeID, @Adult1PriceID, @Adult2PriceID, @Adult3PriceID, @Adult4PriceID, @ExtraPriceID, @ChildPriceID, @IsSpecialRate, 
					CONVERT(INT,FORMAT(@FromDate,'yyyyMMdd')), CONVERT(INT,FORMAT(@ToDate,'yyyyMMdd')), GETDATE(),@UserID)
			
					SET @NewRateID = SCOPE_IDENTITY();

					IF @RateID = 0
						SET @Message = 'Room rate has been saved successfully.';
					ELSE
					   SET @Message = 'Room Rate ID: ' + CAST(@RateID AS VARCHAR(10)) + ' has been updated successfully, New room Rate ID: ' + CAST(@NewRateID AS VARCHAR(10)) + ' has been generated.'		
					   																			
					SET @IsSuccess = 1;
				END
			ELSE
				BEGIN					
					SET @RoomType = (SELECT RoomType FROM [room].[RoomType] WHERE RoomTypeID =  @RoomTypeID)

					SET @Message = 'The Rate Code "' + @RateCode + '" already exists for room type '+ @RoomType +'. Please enter unique Rate Code.';																
					SET @IsSuccess = 0; -- error
				END		
		COMMIT TRANSACTION
	END TRY  
	BEGIN CATCH    
		IF (XACT_STATE() = -1) 
		BEGIN  			
			ROLLBACK TRANSACTION;  

			SET @Message = ERROR_MESSAGE();
			SET @IsSuccess = 0; --error
		END;    
    
		IF (XACT_STATE() = 1)  
		BEGIN  			
			COMMIT TRANSACTION;   

			IF @RateID = 0
				SET @Message = 'Room rate has been saved successfully.';
			ELSE
				SET @Message = 'Room Rate ID: ' + CAST(@RateID AS VARCHAR(10)) + ' has been updated successfully, New room Rate ID: ' + CAST(@NewRateID AS VARCHAR(10)) + ' has been generated.'		
					   																			
				SET @IsSuccess = 1;
		END;  

		-------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog] 3,@LocationID,@Act,@UserID	
	END CATCH;

	SELECT @IsSuccess 'IsSuccess', @Message 'Message';
END



