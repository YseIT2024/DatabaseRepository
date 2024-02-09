
CREATE PROC [Housekeeping].[usp_HKLaundryItemprice_IU]
	@ItemID int,
	@ItemName varchar(100),
	@ItemRateCleaning decimal(18,2),
	@ItemRateDryCleaning decimal(18,2),
	@ItemRatePress decimal(18,2),
	@ItemRateRepair decimal(18,2),
	@ExpressServiceCharge decimal(18,2), --percentage
	@ItemRateChild decimal(18,2), --percentage
	@ValidFrom datetime,
	@ValidTo datetime,
	@IsActive bit,
	@userId int,   
	@LocationID int,
	@ItemDescription varchar(100)
AS 
BEGIN
	SET XACT_ABORT ON; 
	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = @ItemName;

	BEGIN TRY		
		BEGIN TRANSACTION							
		
		IF(@ItemID = 0)
		BEGIN
			IF EXISTS (SELECT * FROM [service].[Item] WHERE [Name] = @ItemName)
			BEGIN
				SET @Message = 'Item Name already exists';
			END
			ELSE
			BEGIN
				-- Insert into [service].[Item]
				INSERT INTO [service].[Item]
					([ServiceTypeID], [FoodTypeID], [Name], [ItemNumber], [Description], [Note], [LocationID], [IsAvailable])
				VALUES
					(3, NULL, @ItemName, 1, @ItemDescription, NULL, @LocationID, 1)
			
				SET @ItemID = SCOPE_IDENTITY();

				-- Insert into [Housekeeping].[HKLaundryItemPrice]
				INSERT INTO [Housekeeping].[HKLaundryItemPrice]
					([ItemID],[ItemRateCleaning],[ItemRateDryCleaning],[ItemRatePress]
					,[ItemRateRepair],[ExpressServiceCharge],[ItemRateChild],[ValidFrom],[ValidTo]
					,[IsActive],[CreatedBy],[CreatedOn],[LocationId])
				VALUES
					(@ItemID ,@ItemRateCleaning ,@ItemRateDryCleaning ,@ItemRatePress ,
					@ItemRateRepair ,@ExpressServiceCharge ,@ItemRateChild ,@ValidFrom ,@ValidTo ,
					@IsActive ,@userId ,GETDATE(),@LocationID)

				SET @IsSuccess = 1; --success
				SET @Message = 'New Item has been created successfully';
			END
		END
		ELSE
		BEGIN
			-- Update [service].[Item]
			UPDATE [service].[Item]
			SET 
				[Name] = @ItemName,
				[Description] = @ItemDescription
			WHERE [ItemID] = @ItemID

			-- Update [Housekeeping].[HKLaundryItemPrice]
			UPDATE [Housekeeping].[HKLaundryItemPrice]
			SET
				[ItemRateCleaning] = @ItemRateCleaning,
				[ItemRateDryCleaning] = @ItemRateDryCleaning,
				[ItemRatePress] = @ItemRatePress,
				[ItemRateRepair] = @ItemRateRepair,
				[ExpressServiceCharge] = @ExpressServiceCharge,
				[ItemRateChild] = @ItemRateChild,
				[ValidFrom] = @ValidFrom,
				[ValidTo] = @ValidTo,
				[IsActive] = @IsActive,
				[ModifiedBy] = @userId,
				[ModifiedOn] = GETDATE()
			WHERE [ItemID] = @ItemID

			    SET @IsSuccess = 1; --success
				SET @Message = 'Item Rate Updated successfully';
		END
		
		COMMIT TRANSACTION					
	END TRY  
	BEGIN CATCH    
		IF (XACT_STATE() = -1) 
		BEGIN  			
			ROLLBACK TRANSACTION;  
			SET @Message = ERROR_MESSAGE();
			SET @IsSuccess = 0; --error
			SET @ItemID = -1; --error
		END;  
		
		-- Insert into activity log
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog]20,@LocationID,@Act,@UserID	
	END CATCH;  

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message], @ItemID AS [ItemID]
END
