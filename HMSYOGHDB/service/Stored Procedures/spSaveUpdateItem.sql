
CREATE PROCEDURE [service].[spSaveUpdateItem]
(
	@CurrencyID int,
	@FoodTypeID int,
	@ItemID int,	
	@IsAvailable bit,
	@Rate decimal(18,3),
	@ServiceTypeID int,
	@UserID int,
	@LocationID int,
	@Name varchar(100),
	@Description varchar(250) = NULL,
	@Note varchar(250) = NULL,
	@ItemRateID int
)
AS
BEGIN
	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(200) = '';
	DECLARE @PriceID int;
	DECLARE @ItemNumber int;	
	
	IF NOT EXISTS(SELECT ItemID FROM [service].Item WHERE [Name] = @Name AND LocationID = @LocationID AND ItemID <> @ItemID)
		BEGIN
			IF(@FoodTypeID = 0)
			BEGIN
				SET @FoodTypeID = NULL;
			END

			SELECT @PriceID = PriceID
			FROM currency.Price
			WHERE CurrencyID = @CurrencyID AND Rate = @Rate

			IF(@PriceID IS NULL)
			BEGIN
				INSERT INTO [currency].[Price]
				([Rate], [CurrencyID])
				VALUES(@Rate, @CurrencyID)

				SET @PriceID = SCOPE_IDENTITY();
			END					

			IF(@ItemID = 0) --ALTER
				BEGIN
					SET @ItemNumber = (SELECT MAX(ItemNumber) FROM [service].[Item]);

					IF (@ItemNumber IS NULL OR @ItemNumber = 0)
						BEGIN
							SET @ItemNumber = 100;
						END
					ELSE
						BEGIN
							SET @ItemNumber += 1;	
						END

					INSERT INTO [service].[Item]
					([ServiceTypeID], [FoodTypeID], [Name], [ItemNumber], [Description], [Note], [LocationID], [IsAvailable])
					VALUES(@ServiceTypeID, @FoodTypeID, @Name, @ItemNumber, @Description, @Note, @LocationID, @IsAvailable)

					SET @ItemID = SCOPE_IDENTITY();

					EXEC [service].[spAddNewItemRate] @ItemID,@PriceID

					SET @IsSuccess = 1;
					SET @Message = 'New item/service has been saved successfully.';
				END
			ELSE -- Update
				BEGIN	
					UPDATE [service].[Item]
					SET [ServiceTypeID] = @ServiceTypeID
					,[FoodTypeID] = @FoodTypeID
					,[Name] = @Name					
					,[Description] = @Description
					,[Note] = @Note
					,[IsAvailable] = @IsAvailable
					WHERE ItemID = @ItemID

					SET @Message = 'Item/service has been updated successfully.';
					
					IF(@Rate > 0)
					BEGIN
						EXEC [service].[spAddNewItemRate] @ItemID,@PriceID

						SET @Message = 'New item/service rate has been added successfully.';
					END

					IF(@ItemRateID > 0)
					BEGIN
						UPDATE service.ItemRate
						SET IsActive = 0
						,DeactivateDate = GETDATE()
						WHERE ItemRateID = @ItemRateID		
								
						SET @Message = 'Rate has been updated successfully.';		 
					END

					SET @IsSuccess = 1;
				END
		END
	ELSE
		BEGIN
			SET @IsSuccess = 0;
			SET @Message = 'Item/service Name ' + @Name + ' already exists in the database. Please enter a unique Item/Service Name.';
		END	

	SELECT @IsSuccess [IsSuccess], @Message [Message], @ItemID [ItemID];
END

