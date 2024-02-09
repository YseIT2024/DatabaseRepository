CREATE Proc [service].[usp_LocalTourismPackageIU]
(
	
	@ItemID int =0, --package id:
	@Name varchar(100), --package name
	@LocationID int,
	@ServiceTypeID int,
	@FoodTypeID INT=NULL,
	@ValidFrom date, --ServivePrice Table
	@ValidTo date, --ServivePrice Table
	@ItemNumber int = 0, --Distance:	 	
	@IsAvailable bit,  --IsActive
	@Rate decimal(18,3), --ServivePrice Table
	@Discount decimal(18,3), --ServivePrice Table
	@UserID int,	
	@Description varchar(250) = NULL,
	@Note varchar(250) = NULL,	--Places to cover  
	@MappedCarSegmentIDs AS [service].[dtTourismPackageCarSegemntMap] READONLY,
	@MappedServiceIDs AS [service].[dtTourismPackageServiceMap]  READONLY
	
	--@MappedServiceIDs AS [service].[dtTourismPackageCarSegemntMap] READONLY,
	--@MappedCarSegmentIDs AS [service].[dtTourismPackageCarSegmentMap]  READONLY
	         
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
						([ItemID],[ItemRate],[Discount],[ValidFrom],[ValidTo]
						,[IsActive],[CreatedBy],[CreatedOn],[ModifiedBy]
						,[ModifiedOn])
				VALUES
						(@ItemID,@Rate,@Discount, @ValidFrom, @ValidTo,1,@UserID,GETDATE(), @UserID,GETDATE())

				
				--------------Begin Insert into CarSegment Mapping-------------------
				INSERT INTO [service].[TourPackageCarMapping]
						([TourPackageServiceID],[CarServiceID],[CreatedBy],[CreateDate])				
						SELECT @ItemID,[CarServiceID], @UserID,GETDATE() FROM @MappedCarSegmentIDs

				--------------End Insert into CarSegment Mapping-----------------

				------------Insert into ComplementaryServic Mapping-------------------
				
				INSERT INTO [service].[TourPackageServiceMapping]
						   ([TourPackageServiceID],[ComplimentaryServiceID],[CreatedBy],[CreateDate])					 
						   SELECT @ItemID,ComplimentaryServiceID,@UserID,GETDATE() FROM @MappedServiceIDs						   

				----------------End into ComplementaryServic Mapping--------------------


					SET @IsSuccess = 1;
					SET @Message = 'New Tourism Package has been saved successfully.';
		END
	ELSE -- Update
			BEGIN	
				UPDATE [service].[Item]
					SET [ServiceTypeID] = @ServiceTypeID
					,[FoodTypeID] = @FoodTypeID,		[Name] = @Name	
					,[ItemNumber]=@ItemNumber,			[Description] = @Description
					,[Note] = @Note,					[LocationID]=@LocationID
					,[IsAvailable] = @IsAvailable
					WHERE ItemID = @ItemID						
				
				UPDATE [service].[ItemPrice] 
					SET [ItemRate] = @Rate,				[Discount] = @Discount,
						[ValidFrom] = @ValidFrom,		[ValidTo] = @ValidTo,
						[IsActive] = [IsActive],		[ModifiedBy] = @UserID,
						[ModifiedOn] = GETDATE()
					WHERE  ItemID = @ItemID and [IsActive]=1 --and ItemPriceID = @PriceID		
					
					
					--------------Begin Insert into CarSegment Mapping-------------------
					DELETE FROM [service].[TourPackageCarMapping] WHERE [TourPackageServiceID]=@ItemID

					INSERT INTO [service].[TourPackageCarMapping]
						([TourPackageServiceID],[CarServiceID],[CreatedBy],[CreateDate])				
						SELECT @ItemID,[CarServiceID], @UserID,GETDATE() FROM @MappedCarSegmentIDs

				--------------End Insert into CarSegment Mapping-----------------

				------------Insert into ComplementaryServic Mapping-------------------
				DELETE FROM [service].[TourPackageServiceMapping] WHERE [TourPackageServiceID]=@ItemID

				INSERT INTO [service].[TourPackageServiceMapping]
						   ([TourPackageServiceID],[ComplimentaryServiceID],[CreatedBy],[CreateDate])					 
						   SELECT @ItemID,ComplimentaryServiceID,@UserID,GETDATE() FROM @MappedServiceIDs						   

				----------------End into ComplementaryServic Mapping--------------------

						--SET @Message = 'Rate has been updated successfully.';		
						SET @Message = 'Tourism Package has been updated successfully'
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





