CREATE Proc [service].[usp_CarSegmentIU]
(
	@CurrencyID INT = NULL,
	@FoodTypeID INT=NULL,
	@ItemID int =0, --TODO:	
	@IsAvailable bit,
	@Rate decimal(18,3),
	@ServiceTypeID int,
	@UserID int,
	@LocationID int,
	@Name varchar(100),
	@Description varchar(250) = NULL,
	@Note varchar(250) = NULL,
	@ItemRateID INT = NULL,
	@ItemNumber int = 0 --TODO:	
)
AS
BEGIN
	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(200) = '';
	DECLARE @PriceID int;
	--DECLARE @ItemNumber int;	
	
	--IF NOT EXISTS(SELECT ItemID FROM [service].Item WHERE [Name] = @Name AND LocationID = @LocationID AND ItemID <> @ItemID)
	IF(@ItemID < 1)
		BEGIN	
				INSERT INTO [service].[Item]
				([ServiceTypeID], [FoodTypeID], [Name], [ItemNumber], [Description], [Note], [LocationID], [IsAvailable])
				VALUES(@ServiceTypeID, @FoodTypeID, @Name, @ItemNumber, @Description, @Note, @LocationID, @IsAvailable)

				--	SET @ItemID = (SELECT MAX(ItemID) FROM [service].[Item] WHERE ServiceTypeID=@ServiceTypeID);					

				SET @ItemID = SCOPE_IDENTITY();

			--		EXEC [service].[spAddNewItemRate] @ItemID,@PriceID

				INSERT INTO [service].[ItemPrice] 
						([ItemID],[ItemRate],[ValidFrom],[ValidTo]
						,[IsActive],[CreatedBy],[CreatedOn],[ModifiedBy]
						,[ModifiedOn])
				VALUES
						(@ItemID,@Rate, GETDATE(), GETDATE(),1,@UserID,GETDATE(), @UserID,GETDATE())

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
					,[ItemNumber] = @ItemNumber
					WHERE ItemID = @ItemID

				--SET @Message = 'Item/service has been updated successfully.';
					
					--IF(@Rate > 0)
					--BEGIN
					--	EXEC [service].[spAddNewItemRate] @ItemID,@PriceID

					--	SET @Message = 'New item/service rate has been added successfully.';
					--END

					--IF(@ItemRateID > 0)
					--BEGIN
						UPDATE [service].[ItemPrice] 
						SET [ItemRate] = @Rate,
						IsActive = [IsActive]
						--,DeactivateDate = GETDATE()
						WHERE  ItemID = @ItemID
						--ItemRateID = @ItemRateID		
								
						--SET @Message = 'Rate has been updated successfully.';		
						SET @Message = 'Item/service has been updated successfully'
					--END

					SET @IsSuccess = 1;
			END		
	--ELSE
	--	BEGIN
	--		SET @IsSuccess = 0;
	--		SET @Message = 'Item/service Name ' + @Name + ' already exists in the database. Please enter a unique Item/Service Name.';
	--	END	

	SELECT @IsSuccess [IsSuccess], @Message [Message], @ItemID [ItemID];
END





